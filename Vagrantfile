# vi: set ft=ruby :
require 'yaml'

begin
  # Load config
  yaml_config = File.join(File.dirname(__FILE__), "config.yaml")
  config = nil

  File.open(yaml_config) do |fd|
    config = YAML.load(fd.read)
  end

  nodes          = config["nodes"]
  profiles       = config["profiles"]

  nodes.each do |node|

    # Set default PE configuration, and allow node overriding of these values
    defaults = {"pe" => config['pe']}

    node.merge!(defaults) do |key, oldval, newval|

      if oldval.is_a? Hash
        newval.merge oldval
      else
        warn "Tried to merge #{key} => [#{oldval}, #{newval}], wrong times. Using old val."
        oldval
      end
    end

    profile  = node["profile"]
    node.merge! profiles[profile]
  end
rescue => e
  puts "Malformed or missing config.yaml: #{e}"
  puts e.backtrace
  exit!(1)
end

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
    shell.inline = <<-EOT
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
    shell.inline = <<-EOT
sed -i '
/modulepath/ {
/vagrant/ !s,$,:/modules,
}
' /etc/puppetlabs/puppet/puppet.conf
EOT
  end

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
  attributes["forwards"].each do |(src, dest)|
    node.vm.forward_port src, dest
  end if attributes["forwards"] # <-- I am a monster

  # Add in optional per-node configuration
  node.vm.box_url = attributes["boxurl"] if attributes["boxurl"]
  node.vm.network :hostonly, attributes["address"] if attributes["address"]
  node.vm.boot_mode = attributes[:gui] if attributes[:gui]
end

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

  # Set the machine hostname
  node.vm.provision :shell do |shell|
    shell.inline = %{hostname #{attributes["name"]}}
  end

  node.vm.provision :shell do |shell|
    shell.inline = %{domainname puppetlabs.pants}
  end
end

def install_pe(config, node, attributes)

  # Customize the answers file for each node
  node.vm.provision :shell do |shell|
    shell.inline = %{sed -e 's/%%CERTNAME%%/#{attributes["name"]}/' < /vagrant/answers/#{attributes["role"]}.txt > /tmp/answers.txt}
  end

  # Assemble the installer command
  fragments = []
  fragments << "2>&1"
  fragments << attributes['pe']['installer']['executable']
  fragments << '-a /tmp/answers.txt'
  fragments << attributes['pe']['installer']['args'].join(' ')

  installer_cmd = fragments.join(' ').gsub(':version', attributes['pe']['version'])

  # Install PE
  node.vm.provision :shell do |shell|
    shell.inline = <<-EOT
if ! [ -f /opt/pe_version ]; then
    #{installer_cmd}
fi
    EOT
  end
end

Vagrant::Config.run do |config|

  # Generate a list of nodes with static IP addresses
  hosts_entries = nodes.select {|h| h["address"]}.map {|h| %{#{h["address"]} #{h["name"]}}}

  # Tweak each host for Puppet Enterprise, and then install PE itself.
  nodes.each do |attributes|
    config.vm.define attributes["name"] do |node|

      attributes["hosts_entries"] = hosts_entries

      configure_node(config, node, attributes)
      provision_node(config, node, attributes)
      install_pe(config, node, attributes)

      if attributes["role"].match /master/
        provision_master(config, node, attributes)
      end
    end
  end
end
