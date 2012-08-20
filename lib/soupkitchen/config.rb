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

  def load_all(*paths)
    paths.flatten.each do |path|
      p path
      if File.file?(path) and path.match /\.yaml$/
        load_file(path)
      elsif File.directory? path
        load_all Dir["#{path}/*"]
      else
        puts "#{path} is neither a YAML file nor a directory, ignoring it."
      end
    end
  end

  def load_file(filename)
    localdata = YAML.load(File.read(filename))
    raise "Expected a top level hash from #{filename}, got a #{localdata.class}" unless localdata.is_a? Hash
    @data.merge!(localdata)
  end

  def nodes;    @data["nodes"]; end
  def profiles; @data["profiles"]; end
  def pe;       @data["pe"]; end

  # Delegate any unknown methods to our data, so we can pretend that we are
  # the parsed YAML config.
  def method_missing(meth, *args, &block)
    if @data.respond_to? meth
      args << block if block_given?
      puts "delegating #{meth}"
      @data.send(meth, args)
    else
      super
    end
  end
end
