require 'soupkitchen'
require 'vagrant'

class SoupKitchen::Node

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
    node.vm.box = @attrs["boxname"]

    node.vm.network :hostonly, @attrs["address"]  if @attrs["address"]
    if @attrs["forwards"]
      @attrs["forwards"].each { |h| node.vm.forward_port h["source"], h["dest"] }
    end

    # Add in optional per-node configuration
    node.vm.box_url          = @attrs["boxurl"]   if @attrs["boxurl"]
    node.vm.boot_mode        = @attrs["gui"]      if @attrs["gui"]

    node.vm.provision :puppet_enterprise_bootstrap do |pe|
      pe.role = @attrs["role"] if @attrs["role"]
    end
  end

  addrole(:master) do |node|
    # Manifests and modules need to be mounted on the master via shared folders,
    # but the default /vagrant mount has permissions and ownership that conflicts
    # with the master and pe-puppet. We mount these folders separately with
    # loosened permissions.
    node.vm.share_folder 'manifests', '/manifests', './manifests', :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'
    node.vm.share_folder 'modules', '/modules', './modules',  :extra => 'fmode=644,dmode=755,fmask=022,dmask=022'

    # Boost RAM for the master so that activemq doesn't asplode
    node.vm.customize([ "modifyvm", :id, "--memory", "1024" ])
  end

  def initialize(yaml_attrs)
    @attrs = yaml_attrs
  end

  def define!
    Vagrant::Config.run do |config|
      config.vm.define @attrs["name"] do |node|

        entry = "#{@attrs["address"]} master"

        node.vm.provision :shell do |shell|
          shell.inline = %{grep "#{entry}" /etc/hosts || echo "#{entry}" >> /etc/hosts}
        end
        instance_exec(node, &(self.class.getrole(:base)))

        if(sym = @attrs["role"] and blk = self.class.getrole(sym.intern))
          instance_exec(node, &blk)
        end
      end
    end
  end
end
