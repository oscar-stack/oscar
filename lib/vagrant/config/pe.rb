require 'vagrant'
require 'uri'

class Vagrant::Config::SoupKitchen < Vagrant::Config::Base
  attr_writer :download_root

  def download_root
    @download_root || 'https://pm.puppetlabs.com/puppet-enterprise'
  end

  def validate(env, errors)
    URI.parse(@download_root)
  rescue
    # TODO I18n
    errors.add("Invalid download root for Puppet Enterprise")
  end
end

Vagrant.config_keys.register(:soupkitchen) { Vagrant::Config::SoupKitchen }
