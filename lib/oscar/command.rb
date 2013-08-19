require 'vagrant'
module Oscar
  class Command < Vagrant.plugin('2', :command)

    require 'oscar/command/helpers'
    include Oscar::Command::Helpers

    require 'oscar/command/init'
    require 'oscar/command/init_vms'

    def initialize(argv, env)
      @argv     = argv
      @env      = env
      @cmd_name = 'oscar'

      split_argv
      register_subcommands
    end

    def execute
      invoke_subcommand
    end

    private

    def register_subcommands
      @subcommands = Vagrant::Registry.new

      @subcommands.register('init') do
        Oscar::Command::Init
      end

      @subcommands.register('init-vms') do
        Oscar::Command::InitVMs
      end
    end
  end
end
