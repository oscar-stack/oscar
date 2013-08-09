require 'fileutils'
class Oscar::Command::Init < Vagrant.plugin('2', :command)

  include Oscar::Command::Helpers

  def initialize(argv, env)
    @argv     = argv
    @env      = env
    @cmd_name = 'oscar init'

    @opts = {:provider => 'virtualbox'}

    split_argv
  end

  def execute
    working_dir   = Dir.getwd
    template_root = File.join(Oscar.template_root, 'oscar-init-skeleton')

    FileUtils.cp   File.join(template_root, 'Vagrantfile'), working_dir
    FileUtils.cp_r File.join(template_root, @opts[:provider]), File.join(working_dir, 'config')

    @env.ui.info I18n.t('oscar.command.init.default')
  end

  private

  def parser
    OptionParser.new do |o|
      o.banner    = "Usage: vagrant #{@cmd_name} [<args>]"
      o.separator = ''

      o.on('-p', '--provider=val', String, 'The Vagrant provider type to template') do |val|
        @opts[:provider] = val
      end
    end
  end
end
