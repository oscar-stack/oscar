$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'date'
require 'oscar/version'

Gem::Specification.new do |gem|
  gem.name    = 'oscar'
  gem.version = Oscar::VERSION
  gem.date    = Date.today.to_s

  gem.summary     = 'Easy mode Puppet Enterprise provisioning'
  gem.description = <<-EOD
    Oscar is a series of extensions to simplify building out a Puppet Enterprise
    environment. It handles networking configuration and fetching/installing
    Puppet Enterprise.
  EOD

  gem.authors  = ['Adrien Thebo', 'Charlie Sharpsteen']
  gem.email    = ['adrien@somethingsinistral.net', 'source@sharpsteen.net']
  gem.homepage = 'https://github.com/oscar-stack/oscar'

  gem.add_dependency 'vagrant-hosts',          '~> 2.8'
  gem.add_dependency 'vagrant-pe_build',       '>= 0.19.0', '< 1.0'
  gem.add_dependency 'vagrant-auto_network',   '~> 1.0'
  gem.add_dependency 'vagrant-config_builder', '~> 1.3'
  gem.add_dependency 'vagrant-bolt',           '~> 0.1'

  gem.files        = %x{git ls-files -z}.split("\0")
  gem.require_path = 'lib'

  gem.license = 'Apache-2.0'
end
