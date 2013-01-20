require 'oscar'
require 'ipaddress'

class Oscar::Networking

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
    arr << ['127.0.1.1', ["#{node.name}.#{@domainname}", node.name]]

    @nodes.each_pair { |address, n| arr << [address, [n.name, "#{n.name}.#{@domainname}"]] }

    arr
  end
end
