require 'vagrant'
require 'uri'
require 'pebuild'

class PEBuild::Config < Vagrant::Config::Base
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
    @filename || "puppet-enterprise-#{@default_version}-all.tar.gz"
  end

  def validate(env, errors)
    URI.parse(@download_root)
  rescue
    # TODO I18n
    errors.add("Invalid download root for Puppet Enterprise")
  end
end
