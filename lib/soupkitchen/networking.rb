require 'soupkitchen'
require 'ipaddress'

class SoupKitchen::Networking

  def initialize(yaml_config)

    range = yaml_config["pool"]

    @network = IPAddress.parse(range)

    @pool = []

    @network.each_host { |h| @pool << h }
    @iterator = @pool.each

    @nodes = {}
  end

  def register(node)
    next_addr = @iterator.next.to_s

    node.networking = self
    node.address    = next_addr

    @nodes[next_addr] = node
  end

end
