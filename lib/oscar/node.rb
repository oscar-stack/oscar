require 'oscar'
require 'vagrant'

require 'vagrant-hosts'

class Oscar::Node

  class << self
    def addrole(name, &block)
      @roles ||= {}
      @roles[name] = block
    end

    def getrole(name)
      @roles[name] if @roles
    end
  end

  addrole(:base) do |node|
    node.vm.box = @boxname

    if @forwards
      @forwards.each { |h| node.vm.forward_port h["source"], h["dest"] }
    end

    node.vm.network :hostonly, @address
    # Add in optional per-node configuration
    node.vm.box_url          = @boxurl if @boxurl
    node.vm.boot_mode        = @gui    if @gui

    host_entries = @networking.hosts_for(self)

    node.vm.provision :hosts do |h|
      host_entries.each { |(address, aliases)| h.add_host address, aliases }

      h.add_ipv6_multicast
    end

    node.vm.provision :puppet_enterprise_bootstrap do |pe|
      pe.role = @role if @role
    end
  end

  addrole(:master) do |node|
    # Manifests and modules need to be mounted on the master via shared folders,
    # but the default /vagrant mount has permissions and ownership that conflicts
    # with the master and pe-puppet. We mount these folders separately with
    # loosened permissions.
    node.vm.share_folder 'manifests', '/manifests', './manifests', :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'
    node.vm.share_folder 'modules',   '/modules',   './modules',   :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'

    # Boost RAM for the master so that activemq doesn't asplode
    node.vm.customize([ "modifyvm", :id, "--memory", "1024" ])
  end

  attr_accessor :address
  attr_writer :networking # Callback attribute for retrieving hosts

  attr_reader :name, :boxname, :boxurl, :role
  attr_reader :forwards # really?

  def initialize(yaml_attrs)
    @attrs = yaml_attrs

    @name    = @attrs["name"]
    @address = @attrs["address"]
    @role    = @attrs["role"].intern if @attrs["role"]

    @boxurl   = @attrs["boxurl"]
    @boxname  = @attrs["boxname"]
    @forwards = @attrs["forwards"]
    @gui      = @attrs["gui"]
  end

  def define(config)

    blk = lambda do |config|
      config.vm.define @name do |node|

        instance_exec(node, &(self.class.getrole(:base)))

        if (blk = self.class.getrole(@role))
          instance_exec(node, &blk)
        end
      end
    end

    blk.call(config)
  end
end
