require 'oscar/skeleton'

class Oscar::Command::Init < Vagrant.plugin('2', :command)

  include Oscar::Command::Helpers

  def initialize(argv, env)
    @argv     = argv
    @env      = env
    @cmd_name = 'oscar init'

    @provider = nil

    split_argv
  end

  def execute
    argv = parse_options(parser)

    skeleton = Oscar::Skeleton.new(@env, @provider)
    skeleton.generate

    @env.ui.info I18n.t('oscar.command.init.default')
  end

  private

  def parser
    OptionParser.new do |o|
      o.banner = "Usage: vagrant #{@cmd_name} [<args>]"
      o.separator ''

      o.on('-p', '--provider=val', String, 'The Vagrant provider type to template') do |val|
        @provider = val
      end
    end
  end
end
