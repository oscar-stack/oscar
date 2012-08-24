require 'pe_build'
require 'vagrant'

class PEBuild::Command < Vagrant::Command::Base
  def initialize(argv, env)
    @argv, @env = argv, env

    @main_args, @subcommand, @sub_args = split_main_and_subcommand(argv)

    # Is this even remotely sane? Are we verging on cargo cult programming?
    @subcommands = Vagrant::Registry.new

    @subcommands.register('download') { PEBuild::Command::Download }
    @subcommands.register('list')     { PEBuild::Command::List }
  end

  def execute
    if @subcommand and (klass = @subcommands.get(@subcommand))
      klass.new(@argv, @env).execute
    elsif @subcommand
      raise "Unrecognized subcommand #{@subcommand}"
    else
      PEBuild::Command::List.new(@argv, @env).execute
    end
  end
end

require 'pe_build/command/list'
require 'pe_build/command/download'

Vagrant.commands.register(:pe_build) { PEBuild::Command }
