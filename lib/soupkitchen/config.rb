require 'soupkitchen'
require 'yaml'
require 'kwalify'

class SoupKitchen::Config

  attr_reader :data

  def initialize(searchpath)
    @data = {}

    schema_path = File.expand_path(File.join(File.dirname(__FILE__), 'schema.yaml'))
    schema      = YAML.load_file schema_path
    validator   = Kwalify::Validator.new(schema)
    @parser     = Kwalify::Yaml::Parser.new(validator)

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
  # @raise [TypeError] If the YAML in a given file does not have a hash at top level
  def load_file(filename)
    localdata = @parser.parse_file(filename)
    errors    = @parser.errors

    if (errors and not errors.empty?)
      errors.each do |err|
        puts "#{err.linenum}:#{err.column} [#{err.path}] #{err.message}"
      end
      raise TypeError
    else
      @data.merge!(localdata)
    end
  end

  def nodes;    @data["nodes"]; end
  def profiles; @data["profiles"]; end

  # Generate a full node configuration for a given node
  #
  # Provides a data structure that looks like the following:
  #
  # <code>
  # {
  #   "name" => "nodename",
  #   "role" => "roletype",
  #   "address" => "ip address",
  #
  #   "forwards" => {
  #     'local port' => 'remote port',
  #   }
  #
  #   "profile" => {
  #     "boxname" => "box shortname",
  #     "boxurl"  => "box URL",
  #   },
  # }
  # </code>
  #
  # @return [Hash]
  def node_config(node_data)
    defaults = {} # XXX Code rot, figure out use or remove.
    node_data.merge!(defaults) do |key, oldval, newval|
      if oldval.is_a? Hash
        newval.merge oldval
      else
        warn "Tried to merge hash values with #{key} => [#{oldval}, #{newval}], but was not a hash. Using #{oldval}."
        oldval
      end
    end
    profile  = node_data["profile"]
    node_data.merge! profiles.find {|p| p["name"] == profile}

    node_data
  end

  # Delegate any unknown methods to our data, so we can pretend that we are
  # the parsed YAML config.
  def method_missing(meth, *args, &block)
    if @data.respond_to? meth
      args << block if block_given?
      @data.send(meth, args)
    else
      super
    end
  end
end
