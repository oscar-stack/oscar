require 'vagrant'
require 'vagrant-batch/provisioner'

Vagrant.provisioners.register(:batch) { VagrantBatch::Provisioner }
