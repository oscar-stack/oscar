Oscar
=====

Oscar is a set of Vagrant plugins and templates that build up a full Puppet
Enterprise environment based on top of Vagrant.

Synopsis
--------

Initialize the base Oscar environment:

    └> vagrant oscar init
    A stub Vagrantfile has been placed in this directory and default configurations
    have been placed into the `config` directory. You can now run `vagrant up` to start
    your Oscar built environment, courtesy of Vagrant.

Define a set of VMs:

    └> vagrant oscar init-vms \
      --master master=puppetlabs/centos-7.2-64-nocm \
      --agent first=puppetlabs/centos-6.6-64-nocm  \
      --agent second=puppetlabs/ubuntu-14.04-64-nocm
    Your environment has been initialized with the following configuration:

And build everything:

    └> vagrant up
    Bringing machine 'master' up with 'virtualbox' provider...
    Bringing machine 'first' up with 'virtualbox' provider...
    Bringing machine 'second' up with 'virtualbox' provider...
    [... normal `vagrant up` goes here ...]

Commands
--------

Oscar provides a set commands to generate a working environment from templates.

### `vagrant oscar init`

This command initializes the current working directory with a stub Vagrantfile
that loads Oscar, and generates generic configuration information for use with
PE.

### `vagrant oscar init-vms`

This command generates a set of guest machines inside of the vagrant
environment.

Configuring
-----------

Oscar handles guest machine configuration with YAML.

The default configuration looks something like this:

### `config/roles.yaml`

    ---
    roles:
      pe-puppet-master:
        private_networks:
          - {auto_network: true}
        provider:
          type: virtualbox
          customize:
            - [modifyvm, !ruby/sym id, '--memory', 1024]
        provisioners:
          - {type: hosts}
          - {type: pe_bootstrap, role: !ruby/sym master}
    [...]

### `config/pe_build.yaml`

    ---
    pe_build:
      version: 3.0.0

### `config/vms.yaml`

    ---
    vms:
    - name: master
      box: centos-6-i386
      roles:
      - pe-puppet-master
    - name: agent
      box: debian-6-i386
      roles:
      - pe-puppet-agent

Oscar uses `vagrant-config_builder` to handle guest machine configuration.

Installation
------------

    $ vagrant plugin install oscar

Requirements
------------

The plugins used in Oscar require the Vagrant 1.1 plugin API, so Vagrant 1.1+ is
required.
