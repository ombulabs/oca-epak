require 'rspec/core/rake_task'
require File.expand_path("../lib/oca-epak/version", __FILE__)

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--color']
end

task default: :spec

task :build do
  sh "gem build oca-epak.gemspec"
end

task release: :build do
  sh "git push origin master"
  sh "gem push oca-epak-#{Oca::Epak::VERSION}.gem"
  sh("git tag v#{Oca::Epak::VERSION}") rescue nil
  sh("git push --tags")
end

task :console do
  sh "irb -rubygems -I lib -r oca-epak.rb"
end
