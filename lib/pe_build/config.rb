require 'vagrant'
require 'uri'
require 'pe_build'

class PEBuild::Config < Vagrant::Config::Base
  attr_writer :download_root
  attr_writer :version
  attr_writer :filename

  def download_root
    @download_root || 'https://pm.puppetlabs.com/puppet-enterprise'
  end

  def version
    @version || '2.5.3'
  end

  def filename
    @filename || "puppet-enterprise-#{version}-all.tar.gz"
  end

  def validate(env, errors)
    URI.parse(download_root)
  rescue
    # TODO I18n
    errors.add("Invalid download root '#{download_root.inspect}'")
  end
end

Vagrant.config_keys.register(:pe_build) { PEBuild::Config }
