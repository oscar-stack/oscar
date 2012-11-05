require 'oscar'
require 'yaml'
require 'kwalify'

class Oscar::Config

  attr_reader :data

  def initialize
    @data = {}

    schema_path = File.expand_path(File.join(File.dirname(__FILE__), 'schema.yaml'))
    schema      = YAML.load_file schema_path
    validator   = Kwalify::Validator.new(schema)
    @parser     = Kwalify::Yaml::Parser.new(validator)
  end

  def load!(searchpath)
    files = ['config.yaml', 'config'].map { |m| "#{searchpath}/#{m}" }
    load_all files
  end

  # Recursively load any YAML files contained in the given paths.
  def load_all(*paths)
    paths.flatten.each do |path|
      if File.file?(path) and path.match /\.yaml$/
        load_file(path)
      elsif File.directory? path
        load_all Dir["#{path}/*"]
      #else
      #  warn "#{path} is neither a YAML file nor a directory, ignoring it."
      end
    end
  end

  # Load YAML from a file and merge it into the aggregated YAML
  #
  # @raise [TypeError] If the YAML in a given file does not match the configuration schema
  def load_file(filename)
    localdata = @parser.parse_file(filename)
    errors    = @parser.errors

    if (errors and not errors.empty?)
      errors.each do |err|
        puts "#{filename} line #{err.linenum}, column #{err.column}, [kwalify path #{err.path}] #{err.message}"
      end
      raise TypeError
    else
      @data.merge!(localdata)
    end
  end

  # Collects all node configuration as an array of the node structured data.
  #
  # @return [Array<Hash<String, String>>]
  def all_node_configs
    names = @data["nodes"].map { |h| h['name'] }
    names.map { |n| node_config(n) }
  end

  # Provides the structured data representation of a node.
  #
  # Configuration priority is 'profile' -> 'role' -> 'node'
  #
  # @param [String] name The name of the node to fetch
  #
  # @return [Hash<String, String>]
  def node_config(node_name)
    config = {}

    unless (node_hash = @data['nodes'].find { |h| h['name'] == node_name })
      raise "Node configuration for #{node_name} not found"
    end

    # Check to see if the node has a profile or role. If one of those values
    # do exist, try to lookup that data and merge it into the config hash.
    ['profile', 'role'].each do |type|
      plural_type = "#{type}s"

      type_name = node_hash[type] # Check to see if we have the requested type
      if (type_name and type_hash = @data[plural_type].find { |t| t['name'] == type_name })
        # The requested type exists in the node hash, and we were able to lookup
        # the related configuration.
        config.merge! type_hash
      else
        # The requested type exists in the node hash, but we were not able to
        # lookup the related configuraion; die messily.
        raise %{#{type.capitalize} configuration "#{type}" for #{node_name} not found}
      end
    end

    # Merge the node hash last so that it takes precedence
    config.merge! node_hash

    config
  end
end
