require 'oscar'

class Oscar::Environment
  attr_reader :networking
  attr_reader :config

  def initialize
    @config     = Oscar::Config.new
    @nodes = []
  end

  def run!
    @networking = Oscar::Networking.new(@config.data["networking"])
    nodes       = @config.all_node_configs

    # TODO make sure that the master is provisioned before any agents.
    nodes.each do |node_attrs|
      node = Oscar::Node.new(node_attrs)
      @networking.register(node)

      @nodes << node
    end

    Vagrant::Config.run do |config|
      @nodes.each { |node| node.define(config) }
    end
  end
end
