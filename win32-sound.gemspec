require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'win32-sound'
  spec.version    = '0.6.2'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Artistic 2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://github.com/djberg96/win32-sound'
  spec.summary    = 'A library for playing with sound on MS Windows.'
  spec.test_file  = 'test/test_win32_sound.rb'
  spec.files      = Dir['**/*']
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']

  spec.add_dependency('ffi')
  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('rake')

  spec.description = <<-EOF
    The win32-sound library provides an interface for playing various
    sounds on MS Windows operating systems, including system sounds and
    wave files, as well as querying and configuring sound related properties.
  EOF
end
