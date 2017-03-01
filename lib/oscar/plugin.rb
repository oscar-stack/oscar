require 'vagrant'

module Oscar
  class Plugin < Vagrant.plugin('2')
    name 'oscar'
    description <<-DESC
Oscar is a set of Vagrant plugins and templates that build up a full Puppet Enterprise environment based on top of Vagrant.
DESC

    command(:oscar) do
      require_relative 'command'
      Oscar::Command
    end
  end
end
