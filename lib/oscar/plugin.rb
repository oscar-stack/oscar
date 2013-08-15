require 'vagrant'

module Oscar
  class Plugin < Vagrant.plugin('2')
    name 'oscar'

    command(:oscar) do
      require_relative 'command'
      Oscar::Command
    end
  end
end
