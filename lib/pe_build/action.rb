require 'vagrant'
require 'vagrant/action/builder'
require 'pebuild'

module PEBuild::Action
end

require 'pebuild/action/download'
require 'pebuild/action/unpackage'

builder = Vagrant::Action::Builder.new do
  use PEBuild::Action::Download
  use PEBuild::Action::Unpackage
end

Vagrant.actions.register :download_pe_build, builder
