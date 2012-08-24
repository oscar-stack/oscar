require 'soupkitchen'
require 'yaml'

class SoupKitchen::Config

  attr_reader :data

  def initialize(*pathglob)
    @data = {}

    # The splat operator has some very radical changes between 1.8 and 1.9
    case pathglob
    when NilClass # IGNORE ME
    when String
      load_file pathglob
    when Array
      load_all pathglob.flatten
    else
      raise ArgumentError, "Expected one or more paths, got a #{pathglob.class}"
    end
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
    localdata = YAML.load(File.read(filename))
    raise TypeError, "Expected a top level hash from #{filename}, got a #{localdata.class}" unless localdata.is_a? Hash
    @data.merge!(localdata)
  end

  def nodes;    @data["nodes"]; end
  def profiles; @data["profiles"]; end
  def pe;       @data["pe"]; end

  # Generate a full node configuration for a given node
  #
  # Provides a data structure that looks like the following:
  #
  # <code>
  # {
  #   "pe" => {
  #     "version"   => "x.x.x",
  #     "installer" => "/command/to/run/installer",
  #   },
  #
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
    # Set default PE configuration, and allow node overriding of these values
    defaults = {"pe" => self.pe}
    node_data.merge!(defaults) do |key, oldval, newval|
      if oldval.is_a? Hash
        newval.merge oldval
      else
        warn "Tried to merge hash values with #{key} => [#{oldval}, #{newval}], but was not a hash. Using #{oldval}."
        oldval
      end
    end
    profile  = node_data["profile"]
    node_data.merge! profiles[profile]

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
