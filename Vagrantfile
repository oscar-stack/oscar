# vi: set ft=ruby :
require 'yaml'

# Load config
yaml_config = File.join(File.dirname(__FILE__), "config.yaml")
config = nil

File.open(yaml_config) do |fd|
  config = YAML.load(fd.read)
end

nodes          = config["nodes"]
profiles       = config["profiles"]
pe_version     = config["pe"]["version"]
installer_path = config["pe"]["installer_path"] % pe_version

nodes.each do |node|
  profile = node["profile"]
  node.merge! profiles[profile]
end

Vagrant::Config.run do |config|

  # This is an extension of the common node definition, as it makes provisions
  # for customizing the master for more seamless interaction with the base
  # system
  configure_master = lambda do |node, attributes|
    # Map master manifests and modules dir to the folders in the vagrant dir
    config.vm.share_folder 'manifests', '/etc/puppetlabs/puppet/manifests', './manifests', :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'
    config.vm.share_folder 'modules', '/etc/puppetlabs/puppet/modules', './modules',  :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'

    # Enable autosigning on the master
    node.vm.provision :shell do |shell|
      shell.inline = %{chmod -R go+rX /etc/puppetlabs/puppet/manifests /etc/puppetlabs/puppet/modules}
    end

    # Boost RAM for the master so that activemq doesn't asplode
    node.vm.customize([ "modifyvm", :id, "--memory", "1024" ])

    # Enable autosigning on the master
    node.vm.provision :shell do |shell|
      shell.inline = %{echo '*' > /etc/puppetlabs/puppet/autosign.conf}
    end
  end

  # Generate a list of nodes with static IP addresses
  hosts_entries = nodes.select {|h| h["address"]}.map {|h| %{#{h["address"]} #{h["name"]}}}

  # Tweak each host for Puppet Enterprise, and then install PE itself.
  nodes.each do |attributes|
    config.vm.define attributes["name"] do |node|
      node.vm.box    = attributes["boxname"]

      attributes["forwards"].each do |(src, dest)|
        node.vm.forward_port src, dest
      end if attributes["forwards"] # <-- I am a monster

      # Add in optional per-node configuration
      node.vm.box_url = attributes["box_url"] if attributes["box_url"]
      node.vm.network :hostonly, attributes["address"] if attributes["address"]
      node.vm.boot_mode = attributes[:gui] if attributes[:gui]

      # Hack in faux DNS
      # Puppet enterprise requires something resembling functioning DNS to
      # be installed correctly
      hosts_entries.each do |entry|
        node.vm.provision :shell do |shell|
          shell.inline = %{grep "#{entry}" /etc/hosts || echo "#{entry}" >> /etc/hosts}
        end
      end

      # Customize the answers file for each node
      node.vm.provision :shell do |shell|
        shell.inline = %{sed -e 's/%%CERTNAME%%/#{attributes["name"]}/' < /vagrant/answers/#{attributes["role"]}.txt > /tmp/answers.txt}
      end

      # Install PE
      node.vm.provision :shell do |shell|
        shell.inline = "#{installer_path} -a /tmp/answers.txt -l /tmp/puppet-enterprise-installer.log || true"
      end

      if attributes["role"] == "master"
        instance_exec(node, attributes, &configure_master)
      end
    end
  end
end
