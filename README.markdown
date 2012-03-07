Insta-PE
========

Create a demo Puppet Enterprise environment from scratch, by simply running
`vagrant up`.

---
To get insta-pe up and running follow these steps:

1. Download the Universal tarball for the version of PE that you want to install and untar it in the files folder
    * `$ cd ~/src/insta-pe/files`
    * `$ wget http://pm.puppetlabs.com/puppet-enterprise/2.0.3/puppet-enterprise-2.0.3-all.tar.gz`
    * `$ tar xvfz puppet-enterprise-2.0.3-all.tar.gz`
2. Update the config.yaml file with the URL of the vagrant box files if you need to import them.
3. `$ vagrant up pe-master`
4. `$ vagrant ssh pe-master`
