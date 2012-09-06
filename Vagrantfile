# lol shim
$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require 'pe_build'
require 'soupkitchen'

SoupKitchen.facehug! File.dirname(__FILE__)

__END__

# Provide provisioning details for this node
def provision_node(config, node, attributes)

  # Hack in faux DNS
  # Puppet enterprise requires something resembling functioning DNS to be
  # installed correctly
  attributes["hosts_entries"].each do |entry|
    node.vm.provision :shell do |shell|
      shell.inline = %{grep "#{entry}" /etc/hosts || echo "#{entry}" >> /etc/hosts}
    end
  end
end


Vagrant::Config.run do |config|
  config.pe_build.download_root = 'http://faro.puppetlabs.lan/Puppet_Enterprise'

  # Generate a list of nodes with static IP addresses
  hosts_entries = nodes.select {|h| h["address"]}.map {|h| %{#{h["address"]} #{h["name"]}}}

  # Tweak each host for Puppet Enterprise, and then install PE itself.
  nodes.each do |attributes|
    config.vm.define attributes["name"] do |node|

      attributes["hosts_entries"] = hosts_entries

      provision_node(config, node, attributes)

      if attributes["role"].match /master/
        provision_master(config, node, attributes)
      end
    end
  end
end
