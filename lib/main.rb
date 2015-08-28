require 'java'
require 'csv'
require 'rexml/document'
require 'yaml'

# Require all of the jar files.
Dir[File.expand_path("#{File.dirname(__FILE__)}/../vendor/*.jar")].each do |jar_file|
  require jar_file
end

# Require all of the lib files.
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'parameter_value_reporter', '**', '*.rb')].each do |ruby_file|
  require ruby_file
end

# Load ars models
require 'ars_models'

# Parse the command line options.
action = ARGV[0]
keyword = ARGV[1]

# Include the parameter value reporter actions
include ParameterValueReporter::Actions

# Helper that loads the config.yml file and creates and returns an ars models context.
def load_config
  if !File.exists?('config.yml')
    raise "The config.yml file is not present in the current directory.  Run -setup to configure this file."
  end

  # Load the config.yml configuration file.
  config = YAML::load_file('config.yml')

  # Create the ars models context given values from the config.yml file.
  context = ArsModels::Context.new({
    :username => config['username'],
    :password => config['password'],
    :server   => config['server'],
    :port     => config['port']
    })
  context
end

# Call the appropriate action method depending on the options passed.
case action
when '-setup'
  setup
when '-version'
  puts ParameterValueReporter::VERSION
when '-help'
  puts <<-HELP
  -setup                    Sets up the config.yml file
  -version                  Prints version number
  -help                     Displays help
  -keyword KEYWORD          Get parameters for handlers that match the
                            entered KEYWORD.
HELP
when '-keyword'
  if keyword.nil?
    puts "A handler id must be entered with the -keyword action. See -help for examples."
  else
    get_parameters(keyword, load_config)
  end
end