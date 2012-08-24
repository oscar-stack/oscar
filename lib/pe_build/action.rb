require 'vagrant'
require 'vagrant/action/builder'
require 'pe_build'

module PEBuild::Action
end

require 'pe_build/action/download'
require 'pe_build/action/unpackage'

builder = Vagrant::Action::Builder.new do
  use PEBuild::Action::Download
end

Vagrant.actions.register :download_pe_build, builder

Vagrant.actions.register(:prep_build, Vagrant::Action::Builder.new do
  use PEBuild::Action::Download
  use PEBuild::Action::Unpackage
end)
