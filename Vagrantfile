# lol shim
$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require 'pe_build'
require 'yaml'
require 'soupkitchen'
require 'vagrant-batch'

config = SoupKitchen::Config.new(File.dirname(__FILE__))
nodes  = config.all_node_configs

# This is an extension of the common node definition, as it makes provisions
# for customizing the master for more seamless interaction with the base
# system
def provision_master(config, node, attributes)

  # Manifests and modules need to be mounted on the master via shared folders,
  # but the default /vagrant mount has permissions and ownership that conflicts
  # with the master and pe-puppet. We mount these folders separately with
  # loosened permissions.
  config.vm.share_folder 'manifests', '/manifests', './manifests', :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'
  config.vm.share_folder 'modules', '/modules', './modules',  :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'

  # Update puppet.conf to add the manifestdir directive to point to the
  # /manifests mount, if the directive isn't already present.
  node.vm.provision :shell do |shell|
    shell.inline = <<-EOT.gsub(/^ */, '')
      sed -i '
      2 {
      /manifest/ !i\
          manifestdir = /manifests
      }
      ' /etc/puppetlabs/puppet/puppet.conf
    EOT
  end

  # Update puppet.conf to add the modulepath directive to point to the
  # /module mount, if it hasn't already been set.
  node.vm.provision :shell do |shell|
    shell.inline = <<-EOT.gsub(/^ */, '')
      sed -i '
      /modulepath/ {
      /vagrant/ !s,$,:/modules,
      }
      ' /etc/puppetlabs/puppet/puppet.conf
    EOT
  end

  # Rewrite the olde site.pp config since it's not used, and warn people
  # about this.
  node.vm.provision :shell do |shell|
    shell.inline = %{echo "# /etc/puppetlabs/puppet/manifests is not used; see /manifests." > /etc/puppetlabs/puppet/manifests/site.pp}
  end

  # Boost RAM for the master so that activemq doesn't asplode
  node.vm.customize([ "modifyvm", :id, "--memory", "1024" ])

  # Enable autosigning on the master
  node.vm.provision :shell do |shell|
    shell.inline = %{echo '*' > /etc/puppetlabs/puppet/autosign.conf}
  end
end

# Adds the vagrant configuration tweaks
def configure_node(config, node, attributes)

  node.vm.box = attributes["boxname"]

  # Apply all specified port forwards
  attributes["forwards"].each { |h| node.vm.forward_port h["source"], h["dest"] } if attributes["forwards"] # <-- I am a monster

  # Add in optional per-node configuration
  node.vm.box_url = attributes['boxurl'] if attributes['boxurl']
  node.vm.network :hostonly, attributes['address'] if attributes['address']
  node.vm.boot_mode = attributes['bootmode'] if attributes['bootmode']
  node.vm.guest = attributes['guest'].to_sym if attributes['guest']
end

# Provide provisioning details for this node
def provision_node(config, node, attributes)

  # Hack in faux DNS
  # Puppet enterprise requires something resembling functioning DNS to be
  # installed correctly
  case attributes['guest']
  when :windows, 'windows'
    provisioner = :batch
    script = attributes['hosts_entries'].map do |entry|
      [
        %{FindStr "#{entry}" %SYSTEMROOT%\\system32\\drivers\\etc\\hosts},
        %{if %ERRORLEVEL% GEQ 1 echo #{entry} >> %SYSTEMROOT%\\system32\\drivers\\etc\\hosts}
      ].join("\r\n")
    end.join("\r\n")
  else
    provisioner = :shell
    script = attributes['hosts_entries'].map do |entry|
      %{grep "#{entry}" /etc/hosts || echo "#{entry}" >> /etc/hosts}
    end.join("\n")
  end

  node.vm.provision provisioner, :inline => script

end

Vagrant::Config.run do |config|
  config.pe_build.download_root = 'http://faro.puppetlabs.lan/Puppet_Enterprise'

  # Generate a list of nodes with static IP addresses
  hosts_entries = nodes.select {|h| h["address"]}.map {|h| %{#{h["address"]} #{h["name"]}}}

  # Tweak each host for Puppet Enterprise, and then install PE itself.
  nodes.each do |attributes|
    config.vm.define attributes["name"] do |node|

      attributes["hosts_entries"] = hosts_entries

      configure_node(config, node, attributes)
      provision_node(config, node, attributes)

      node.vm.provision :puppet_enterprise_bootstrap

      if attributes["role"].match /master/
        provision_master(config, node, attributes)
      end
    end
  end
end
