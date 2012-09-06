require 'soupkitchen'
require 'soupkitchen/config'

class SoupKitchen::Environment
  attr_reader :networking
  attr_reader :config

  def initialize
    @config     = SoupKitchen::Config.new
    #@networking = SoupKitchen::Networking.new
    @nodes  = []
  end

  def run!
    nodes  = @config.all_node_configs

    nodes.each do |node_attrs|
      node = SoupKitchen::Node.new(node_attrs)
      @nodes << node

      #@networking.register(node)
      node.define!
    end
  end
end
