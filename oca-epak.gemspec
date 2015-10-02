Gem::Specification.new do |s|
  s.name        = 'oca-epak'
  s.version     = '0.0.3'
  s.date        = '2015-10-02'
  s.summary     = "OCA E-Pak"
  s.description = "Ruby wrapper for the OCA E-Pak API"
  s.authors     = ["Mauro Otonelli", "Ernesto Tagwerker"]
  s.email       = ["mauro@ombulabs.com", "ernesto@ombulabs.com"]
  s.files       = ["lib/oca-epak.rb"]
  s.homepage    = 'https://github.com/ombulabs/oca-epak'

  s.add_dependency("savon", "~> 2.11")
  s.add_development_dependency("rspec", "~> 3.3")
  s.add_development_dependency("vcr", "~> 2.9")
  s.add_development_dependency("webmock", "~> 1.21")
  s.add_development_dependency("pry-byebug", "~> 3.2")
end
