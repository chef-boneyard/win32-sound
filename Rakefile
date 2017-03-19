require 'rake'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include("**/*.gem", "**/*.rbc")

namespace :gem do
  desc "Create the win32-sound gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read("win32-sound.gemspec"))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec, true)
  end

  desc "Install the win32-sound library"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

desc 'Run the example program'
task :example do
  ruby '-Ilib examples\example_win32_sound.rb'
end

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end

task :default => :test
