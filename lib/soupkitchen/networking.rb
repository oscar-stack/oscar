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

  def hosts_for(node)
    arr = []

    arr << ['127.0.0.1', ['localhost']]
    arr << ['127.0.1.1', [node.name]]

    arr << ['::1', %w{ip6-localhost ip6-loopback}]

    arr << ['fe00::0', ['ip6-localnet']]
    arr << ['ff00::0', ['ip6-mcastprefix']]
    arr << ['ff02::1', ['ip6-allnodes']]
    arr << ['ff02::2', ['ip6-allrouters']]

    @nodes.each_pair { |address, n| arr << [address, [n.name]] }


    arr
  end
end
