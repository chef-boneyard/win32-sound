require 'rubygems'

spec = Gem::Specification.new do |gem|
	gem.name      = 'win32-sound'
	gem.version   = '0.4.2'
	gem.author    = 'Daniel J. Berger'
   gem.license   = 'Artistic 2.0'
	gem.email     = 'djberg96@gmail.com'
	gem.homepage  = 'http://www.rubyforge.org/projects/win32utils'
	gem.platform  = Gem::Platform::RUBY
	gem.summary   = 'A library for playing with sound on MS Windows.'
	gem.test_file = 'test/test_win32_sound.rb'
	gem.has_rdoc  = true
   gem.files     = Dir['**/*'].reject{ |f| f.include?('CVS') }

	gem.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']
	gem.rubyforge_project = 'win32utils'

   gem.add_dependency('windows-pr', '>= 1.0.6')
	
	gem.description = <<-EOF
      The win32-sound library provides an interface for playing various
      sounds on MS Windows operating systems, including system sounds and
      wave files, as well as querying and configuring sound related properties.
   EOF
end

Gem::Builder.new(spec).build
