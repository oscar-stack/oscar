require 'soupkitchen'

class SoupKitchen::Environment
  attr_reader :networking
  attr_reader :config

  def initialize
    @config     = SoupKitchen::Config.new
    @nodes = []
  end

  def run!
    @networking = SoupKitchen::Networking.new(@config.data["networking"])
    nodes       = @config.all_node_configs

    # TODO make sure that the master is provisioned before any agents.
    nodes.each do |node_attrs|
      node = SoupKitchen::Node.new(node_attrs)
      @networking.register(node)

      @nodes << node
    end

    Vagrant::Config.run do |config|
      @nodes.each { |node| node.define(config) }
    end
  end
end
