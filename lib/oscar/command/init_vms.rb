require 'yaml'

class Oscar::Command::InitVMs < Vagrant.plugin('2', :command)

  include Oscar::Command::Helpers

  def initialize(argv, env)
    @argv     = argv
    @env      = env
    @cmd_name = 'oscar init-vms'


    @masters = []
    @agents  = []

    require 'pe_build/release'
    @pe_version = PEBuild::Release::LATEST_VERSION

    split_argv
  end

  def execute
    argv = parse_options(parser)

    write_configs

    @env.ui.info(
      I18n.t(
        'oscar.command.init_vms.settings',
        :masters => @masters.map { |m| "  - #{m}" }.join("\n"),
        :agents  => @agents.map { |m| "  - #{m}" }.join("\n"),
        :pe_version => @pe_version,
      )
    )
  end

  private

  def parser
    OptionParser.new do |o|
      o.banner = "Usage: vagrant #{@cmd_name} [<args>]"
      o.separator ''

      o.on('-m', '--master=val', String, 'The name and basebox for a Puppet master') do |val|
        name, box = val.split('=')
        box ||= 'puppetlabs/centos-7.2-64-nocm'
        @masters << [name, box]
      end

      o.on('-a', '--agent=val', String, 'The name and basebox for a Puppet agent') do |val|
        name, box = val.split('=')
        box ||= 'puppetlabs/centos-7.2-64-nocm'
        @agents << [name, box]
      end

      o.on('-p', '--pe-version=val', String, 'The PE version to install on the VMs') do |val|
        @pe_version = val
      end

      o.on('-h', '--help', 'Display this help message') do
        puts o
        exit 0
      end
    end
  end

  def write_configs
    config_dir = Pathname.new(File.join(Dir.getwd, 'config'))

    vm_config_file = config_dir + 'vms.yaml'
    pe_config_file = config_dir + 'pe_build.yaml'

    config_dir.mkpath unless config_dir.exist?

    vm_config_file.open('w') do |fh|
      yaml = YAML.dump vms
      fh.write(yaml)
    end

    pe_config_file.open('w') do |fh|
      yaml = YAML.dump pe_build
      fh.write(yaml)
    end
  end

  def vms
    vm_list = []

    @masters.each do |(name, box)|
      vm_list << {
        'name'  => name,
        'box'   => box,
        'roles' => ['pe-puppet-master']
      }
    end

    @agents.each do |(name, box)|
      vm_list << {
        'name'  => name,
        'box'   => box,
        'roles' => ['pe-puppet-agent']
      }
    end

    {'vms' => vm_list}
  end

  def pe_build
    {'pe_build' => {'version' => @pe_version}}
  end
end
