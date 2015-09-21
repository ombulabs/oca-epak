Gem::Specification.new do |s|
  s.name        = 'oca-epak'
  s.version     = '0.0.1'
  s.date        = '2015-09-14'
  s.summary     = "OCA E-Pak"
  s.description = "Ruby wrapper for the OCA E-Pak API"
  s.authors     = ["Mauro Otonelli", "Ernesto Tagwerker"]
  s.email       = ["mauro@ombulabs.com", "ernesto@ombulabs.com"]
  s.files       = ["lib/oca-epak.rb"]
  s.homepage    = 'http://rubygems.org/gems/oca-epak'

  s.add_dependency("savon", "~> 2.11.1")
  s.add_development_dependency("rspec", "~> 3.3.0")
  s.add_development_dependency("pry-byebug", "~> 3.2.0")
end
