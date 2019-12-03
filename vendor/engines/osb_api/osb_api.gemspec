$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "osb_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "osb_api"
  s.version     = OsbApi::VERSION
  s.authors     = ["Shahzad Tariq"]
  s.email       = ["shahzad.tariq@nxb.com.pk"]
  s.homepage    = "http://vteams.com"
  s.summary     = "Restful API for open source billing project"
  s.description = "Restful API for open source billing project"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"
  s.add_dependency 'doorkeeper', '~> 1.4.0'
  s.add_dependency 'grape', '~> 0.16.2'
  s.add_dependency 'grape-rabl', '~> 0.3.0'
  s.add_dependency 'grape-doorkeeper', '~> 0.0.2'
  s.add_dependency 'rack-cors'
  s.add_dependency 'grape-swagger'
  s.add_dependency 'grape-swagger-rails'

  #s.add_development_dependency "sqlite3"
end
