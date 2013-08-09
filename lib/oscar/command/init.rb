class Oscar::Command::Init < Vagrant.plugin('2', :command)

  include Oscar::Command::Helpers

  def initialize(argv, env)
    @argv     = arv
    @env      = env
    @cmd_name = 'oscar init'

    split_argv
  end

  def execute
    @env.ui.warn "vagrant #{@cmd_name} not yet implemented"
  end
end
