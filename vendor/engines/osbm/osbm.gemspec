$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "osbm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "osbm"
  s.version     = Osbm::VERSION
  s.authors     = ["Shahzad Tariq"]
  s.email       = ["shahzad.tariq@nxb.com.pk"]
  s.homepage    = "http://www.opensourcebilling.org"
  s.summary     = "MultiTenant module for OpenSourceBilling."
  s.description = "MultiTenant module for OpenSourceBilling."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.15"

  s.add_development_dependency "sqlite3"
end
