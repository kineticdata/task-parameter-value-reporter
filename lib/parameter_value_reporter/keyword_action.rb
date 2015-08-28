module ParameterValueReporter
  module Actions
    TREE_CHUNK_SIZE = 50

    def get_parameters(keyword, context)
      # Load the KS_TSK_Tree form definition.
      form = ArsModels::Form.find('KS_TSK_Tree', :context => context)

      # Build up the parameter names when iterating through the trees.
      @parameter_names = []

      # Build up the parameter headers. This allows us to format the CSV headers as "parameter id (Parameter Display Name)"
      @parameter_header = []

      # Get the Tree and Node name when iterating through the trees.
      @node_info = []

      # Build up the parameter values when iterating through the trees.
      @parameter_values = []

      # Loop until we have processed all of the trees in the environment.
      scanned = 0
      total = nil
      while total.nil? || scanned < total
        # Determine the current page number.  Note that in ars models to get the first records use
        # page 1.
        page = (scanned / TREE_CHUNK_SIZE) + 1
        # Retrieve the KS_TSK_Tree records.  Limiting the call to the TREE_CHUNK_SIZE constant to
        # prevent memory issues.
        entries = form.find_entries(:all, :conditions => %|1=1|, :limit => TREE_CHUNK_SIZE, :page => page)
        # Set the total count
        total = entries.total_entries

        # Iterate through each of the KS_TSK_Tree records.
        entries.each do |entry|
          # Parse the tree xml.
          doc = REXML::Document.new(entry['Tree XML'])
          
          # Iterate over each of the nodes in the tree and get the parameter values.
          REXML::XPath.each(doc, "/taskTree/request") do |node|
            # Get the name for each tree.
            @tree_name = [node.elements["../name"].text]

            # Iterate through each node in the tree
            node.elements.each("task") do |task|
              # If the node ID matches the keyword entered, get the parameters and their values.
              if task.attribute("id").value.include?(keyword)
                @tree_name = [node.elements["../name"].text]
                @parameter_hash = {}

                task.elements.each("parameters/parameter") do |param|
                  @parameter_names << param.attribute("id").value if !@parameter_names.include?(param.attribute("id").value)
                  @parameter_hash[param.attribute("id").value] = param.text if !@parameter_hash.has_key?(param.attribute("id").value)
                  @parameter_header << "#{param.attribute('id').value} (#{param.attribute('label').value})" if !@parameter_header.include?("#{param.attribute('id').value} (#{param.attribute('label').value})")
                end

                @parameter_names.each do |params|
                  @node = [task.attribute("id").value]
                  if @parameter_hash.has_key?(params)
                    @parameter_values << @parameter_hash[params]
                  else
                    @parameter_values << nil
                  end
                end

                @node_info << @tree_name + @node + @parameter_values
                @parameter_values = []
              end
            end
          end
        end

        # Increment the scanned counter for the next iteration.
        scanned += entries.size

        # Print the progress message
        puts "Processed #{scanned} of #{total} trees" if scanned > 0
      end

      timestamp = Time.now.strftime("%Y-%m-%dT%H%M%S%z")
      # Create the CSV file.
      CSV.open("#{keyword}-report-#{timestamp}.csv", 'wb') do |csv|
        # Add the header to the csv file
        csv << ["Tree", "Node"] + @parameter_header
        @node_info.each do |params|
          csv << params
        end
      end

    end
  end
end