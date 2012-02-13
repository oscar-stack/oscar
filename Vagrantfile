# vi: set ft=ruby :

PE_VERSION = "2.0.0"
INSTALLER_PATH = "/vagrant/puppet-enterprise-#{PE_VERSION}-all/puppet-enterprise-installer"

Vagrant::Config.run do |config|

  node_profile = {
    :debian => {
      :boxname   => 'debian-6.0.3-i386',
      :box_url    => 'http://faro.puppetlabs.lan/insta-pe/debian-6.0.3-i386.box',
      :installer => 'debian-6-i386',
    },
    :centos => {
      :boxname   => 'centos-5.7-i386',
      :box_url    => 'http://faro.puppetlabs.lan/insta-pe/centos-5.7-i386.box',
      :installer => 'el-5-i386',
    },
    :ubuntu => {
      :boxname   => 'ubuntu-10.04.2-server-i386',
      :box_url    => 'http://faro.puppetlabs.lan/insta-pe/ubuntu-10.04.2-server-i386.box',
      :installer => 'ubuntu-10.04-i386',
    },
  }

  pe_master = {
    :name    => 'pe-master',
    :role    => :master,
    :address => "10.10.1.2",
    :block   => lambda do |node|
      # Map master manifests and modules dir to the folders in the vagrant dir
      config.vm.share_folder 'manifests', '/etc/puppetlabs/puppet/manifests', './manifests', :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'
      config.vm.share_folder 'modules', '/etc/puppetlabs/puppet/modules', './modules',  :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'
      # Enable autosigning on the master
      node.vm.provision :shell do |shell|
        shell.inline = %{chmod -R go+rX /etc/puppetlabs/puppet/manifests /etc/puppetlabs/puppet/modules}
      end

      # Enable port forwarding for the enterprise console
      node.vm.forward_port 443, 2443

      # Boost RAM for the master so that activemq doesn't asplode
      node.vm.customize([ "modifyvm", :id, "--memory", "1024" ])

      # Enable autosigning on the master
      node.vm.provision :shell do |shell|
        shell.inline = %{echo '*' > /etc/puppetlabs/puppet/autosign.conf}
      end

    end
  }.merge(node_profile[:debian])

  agent1 = {:name => :agent1, :role => :agent}.merge(node_profile[:centos])
  agent2 = {:name => :agent2, :role => :agent}.merge(node_profile[:ubuntu])

  nodes = [pe_master, agent1, agent2]
  #nodes[:agent2] = {:role => :agent}.merge(node_profile[:ubuntu])

  ##############################################################################
  # HERE BE DRAGONS
  ##############################################################################

  # Generate a list of nodes with static IP addresses
  hostsfile = nodes.select {|h| h[:address]}.map {|h| %{#{h[:address]} #{h[:name]}}}.join("\\\n")

  nodes.each do |attributes|
    config.vm.define attributes[:name] do |node|
      node.vm.box    = attributes[:boxname]

      # Add in optional per-node configuration
      node.vm.box_url = attributes[:box_url] if attributes[:box_url]
      node.vm.network :hostonly, attributes[:address] if attributes[:address]
      node.vm.boot_mode = attributes[:gui] if attributes[:gui]

      # Hack in faux DNS
      # Puppet enterprise requires something resembling functioning DNS to
      # be installed correctly
      node.vm.provision :shell do |shell|
        shell.inline = %{grep "#{hostsfile}" /etc/hosts || echo #{hostsfile} >> /etc/hosts}
      end

      # Customize the answers file for each node
      node.vm.provision :shell do |shell|
        shell.inline = %{sed -e 's/%%CERTNAME%%/#{attributes[:name]}/' < /vagrant/answers/#{attributes[:role]}.txt > /tmp/answers.txt}
      end

      # Install PE
      node.vm.provision :shell do |shell|
        shell.inline = "#{INSTALLER_PATH} -a /tmp/answers.txt -l /tmp/puppet-enterprise-installer.log"
      end

      # Run any node specific blocks
      instance_exec(node, &attributes[:block]) if attributes[:block]
    end
  end
end
