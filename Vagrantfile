# -*- mode: ruby -*-
# vi: set ft=ruby :

PE_VERSION = "2.0.1"
INSTALLER_PATH = "/vagrant/puppet-enterprise-#{PE_VERSION}-all/puppet-enterprise-installer"

Vagrant::Config.run do |config|

  node_profile = {
    :debian => {
      :boxname   => 'debian-6.0.3-i386',
      :installer => 'debian-6-i386',
    },
    :centos => {
      :boxname   => 'centos-5.7-i386',
      :installer => 'el-5-i386',
    },
    :ubuntu => {
      :boxname   => 'ubuntu-10.04.2-server-i386',
      :installer => 'ubuntu-10.04-i386',
    },
  }

  nodes = []

  nodes << {
    :name    => 'pe-master',
    :role    => :master,
    :address => "10.10.1.2",
    :block   => lambda do |node|
      node.vm.forward_port 443, 2443
      node.vm.customize([ "modifyvm", :id, "--memory", "1024" ])
    end
  }.merge(node_profile[:debian])

  nodes << {:name => :agent1, :role => :agent}.merge(node_profile[:centos])
  #nodes[:agent2] = {:role => :agent}.merge(node_profile[:ubuntu])

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  ##############################################################################
  # HERE BE DRAGONS
  ##############################################################################

  # Generate a list of nodes with static IP addresses
  hostsfile = nodes.select {|h| h[:address]}.map {|h| %{#{h[:address]} #{h[:name]}}}

  nodes.each do |attributes|
    config.vm.define attributes[:name] do |node|
      node.vm.box = attributes[:boxname]
      node.vm.network :hostonly, attributes[:address] if attributes[:address]

      # Hack in faux DNS
      node.vm.provision :shell do |shell|
        shell.inline = %{grep "#{hostsfile}" /etc/hosts || echo #{hostsfile} >> /etc/hosts}
      end

      # Customize the answers file for each node
      node.vm.provision :shell do |shell|
        shell.inline = %{sed -e 's/%%CERTNAME%%/#{attributes[:name]}/' < /vagrant/answers/#{attributes[:role]}.txt > /tmp/answers.txt}
      end

      # Install PE
      node.vm.provision :shell do |shell|
        shell.inline = "#{INSTALLER_PATH} -D -a /tmp/answers.txt -l /tmp/puppet-enterprise-installer.log"
      end

      # Run any node specific blocks
      instance_exec(node, &attributes[:block]) if attributes[:block]
    end
  end

end
