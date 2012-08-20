Instapants
========

Create a full Puppet Enterprise environment from vagrant base boxes.

Prerequisites
-------------

  * Vagrant 1.0
  * Virtualbox 4.x (4.0 strongly recommended for OSX 10.7)

Installation
------------

    git clone git://github.com/adrienthebo/soupkitchen
    cd soupkitchen

    # You'll need a config.yaml to specify how to build the environment. Contact your
    # friendly neighborhood Puppet support monkey on where this is located. Place
    # this file in the insta-pe directory.
    wget http://your.web.server/insta-pe/config.yaml

    # You'll also need the extracted universal installers for Puppet Enterprise.
    # Place the extracted installers in insta-pe/files.
    cd soupkitchen/files
    tar xvf puppet-enterprise-X.Y.Z.tar.gz

    # soupkitchen assumes the you either have all your vagrant boxes already added or
    # are hosted on a webserver.
    vagrant up

Configuration
-------------

Configuration is provided through a yaml file. (Yes, the vagrant config file
has a config file. Deal with it.) The top level values are all keys. You'll
have something like this:

    ---
    # Configuration settings for Puppet Enterprise.
    pe:
      # The version of PE to install. Using a version of 0.0.0 disables the installation
      version: 2.5.1
      installer_path: /vagrant/files/puppet-enterprise-%s-all/puppet-enterprise-installer
      installer:
        # The program to execute to run the PE install. You can insert 'bash -x' to do a trace
        # of the installation. Any string containing :version will be replaced with the current version.
        executable: /vagrant/files/puppet-enterprise-:version-all/puppet-enterprise-installer
        args:
          # Additional arguments to pass to the installer
          - "-l /root/puppet-enterprise-installer.log"
          - "-D"
          - "| tee /root/installer-all.log"

    # Profiles are generic configurations for a basebox
    profiles:
      # One or more key/value pairs, where the name is the profile name and the values are hashes.
      debian:
        # The vagrant base box to use.
        boxname: debian-6.0.4-i386
        # The URL that the box can be downloaded from. This is optional
        boxurl: http://your.web.server/insta-pe/debian-6.0.4-i386.box
      # add more profiles as necessary

    # Your actual node definitions. This is an array of hashes
    nodes:
      -
        # name: the name of the node to address with vagrant commands
        name: master
        # role: one of (master, agent). Self explanatory.
        role: master
        # The name of the profile to use in the previous section.
        profile: debian
        # The IP address to assign for the host
        address: 10.16.1.2
        # A hash where the keys are VM port names and the values are hypervisor port names. Optional.
        # You'll want to forward 443 on the master to your hypervisor for access to the PEC.
        forwards:
          443: 20443

You can also view the config.yaml.example in this directory.

Caveats
-------

Do not look at the Vagrantfile in this directory. You'll go blind.
