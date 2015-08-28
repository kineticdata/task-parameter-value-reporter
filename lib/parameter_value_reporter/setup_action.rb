module ParameterValueReporter
  module Actions
    # The setup action helps the user automatically generate the config.yml file.  It will prompt the
    # user for each of the configuration values and write them to the config.yml file in the current
    # directory.  Note that it will overwrite an existing config.yml file.
    def setup
      puts "Enter the following values to configure connection information for your Kinetic Task enviornment. " +
        "If you enter an incorrect value, you can update the .yml file manually or re-run this setup process. " +
        "The configuration file will be named config.yml and it will be created in the current directory."

      # Initialize the config hash.
      config = {}

      # Prompt the user for the configuration values.
      puts "Username:"
      config['username'] = STDIN.gets.chomp
      puts "Password:"
      config['password'] = STDIN.gets.chomp
      puts "Remedy Server:"
      config['server'] = STDIN.gets.chomp
      puts "Port Number:"
      config['port'] = STDIN.gets.chomp

      # Convert the config value to YAML and write it to the config.yml file.
      File.open('config.yml', 'w') {|file| file.write(config.to_yaml)}
    end
  end
end
