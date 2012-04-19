Insta-PE
========

Create a full Puppet Enterprise environment from vagrant base boxes.

Requirements
------------

  * Vagrant 1.0
  * Virtualbox 4.x (4.0 strongly recommended for OSX 10.7)

Necessary Files
---------------

You'll need a config.yaml to specify how to build the environment. Contact your
friendly neighborhood Puppet support monkey on where this is located. Place
this file in the insta-pe directory.

You'll also need the extracted universtal installers for Puppet Enterprise.
Place the extracted installers in insta-pe/files.

insta-pe assumes the you either have all your vagrant boxes already added or
are hosted on a webserver.

Installation
------------

    git clone git://github.com/adrienthebo/insta-pe
    cd insta-pe
    wget http://your.web.server/insta-pe/config.yaml
    vagrant up

Configuration
-------------

Configuration is provided through a yaml file. (Yes, the vagrant config file
has a config file. Deal with it.) The top level values are all keys. You'll
have something like this:

    ---
    # Configuration settings for Puppet Enterprise.
    pe:
      # The version of PE to install
      version: 2.5.1
      # The location of the installer. It's recommended that you use this value.
      # This is a docstring format, so %s will be replaced with the version variable above
      installer_path: /vagrant/files/puppet-enterprise-%s-all/puppet-enterprise-installer

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
