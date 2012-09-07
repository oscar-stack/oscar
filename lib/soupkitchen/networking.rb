require 'soupkitchen'
require 'ipaddress'

class SoupKitchen::Networking

  def initialize(yaml_config)

    range       = yaml_config["pool"]
    @domainname = yaml_config["domainname"]
    @network = IPAddress.parse(range)

    @pool  = []
    @nodes = {}

    @network.each_host { |h| @pool << h }
    @iterator = @pool.each

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
    arr << ['127.0.1.1', [node.name, "#{node.name}.#{@domainname}"]]

    arr << ['::1', %w{ip6-localhost ip6-loopback}]

    arr << ['fe00::0', ['ip6-localnet']]
    arr << ['ff00::0', ['ip6-mcastprefix']]
    arr << ['ff02::1', ['ip6-allnodes']]
    arr << ['ff02::2', ['ip6-allrouters']]

    @nodes.each_pair { |address, n| arr << [address, [n.name, "#{n.name}.#{@domainname}"]] }


    arr
  end
end
