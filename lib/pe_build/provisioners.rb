require 'pe_build'
require 'vagrant'

module PEBuild::Provisioners; end

require 'pe_build/provisioners/puppet_enterprise_bootstrap'
#require 'pe_build/provisioners/puppet_enterprise'

Vagrant.provisioners.register(:puppet_enterprise_bootstrap) { PEBuild::Provisioners::PuppetEnterpriseBootstrap}
