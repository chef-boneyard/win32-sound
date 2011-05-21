require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'win32-sound'
  spec.version   = '0.4.3'
  spec.author    = 'Daniel J. Berger'
  spec.license   = 'Artistic 2.0'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'http://www.rubyforge.org/projects/win32utils'
  spec.platform  = Gem::Platform.new('universal-mswin32')
  spec.summary   = 'A library for playing with sound on MS Windows.'
  spec.test_file = 'test/test_win32_sound.rb'
  spec.files     = Dir['**/*'] << ".gemtest"

  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']
  spec.rubyforge_project = 'win32utils'

  spec.add_dependency('windows-pr', '>= 1.0.6')

  spec.description = <<-EOF
    The win32-sound library provides an interface for playing various
    sounds on MS Windows operating systems, including system sounds and
    wave files, as well as querying and configuring sound related properties.
  EOF
end
