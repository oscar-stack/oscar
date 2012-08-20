require 'soupkitchen'
require 'yaml'

class SoupKitchen::Config

  attr_reader :data

  def initialize(paths = nil)
    @data = {}
  end

  def load_all(*paths)
    paths.each do |path|
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
end
