require 'vagrant'
require 'uri'

class Vagrant::Config::SoupKitchen < Vagrant::Config::Base
  attr_writer :download_root
  attr_writer :default_version
  attr_writer :filename

  def download_root
    @download_root || 'https://pm.puppetlabs.com/puppet-enterprise'
  end

  def default_version
    @default_version || '2.5.3'
  end

  def filename
    @filename || 'puppet-enterprise-2.5.3-all.tar.gz'
  end

  def validate(env, errors)
    URI.parse(@download_root)
  rescue
    # TODO I18n
    errors.add("Invalid download root for Puppet Enterprise")
  end
end
