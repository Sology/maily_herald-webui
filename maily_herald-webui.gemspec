$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "maily_herald/webui/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "maily_herald-webui"
  s.version     = MailyHerald::Webui::VERSION
  s.authors     = ["Łukasz Jachymczyk"]
  s.email       = ["lukasz@sology.eu"]
  s.homepage    = "http://mailyherald.org"
  s.license     = "LGPL-3.0"
  s.description = s.summary = "Web UI for MailyHerald - Email processing solution for Ruby on Rails applications"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

	s.add_dependency 'maily_herald', "~>1.0.0"
	s.add_dependency "smart_listing", "~>1.2.0"
	s.add_dependency "haml"
	s.add_dependency "coffee-rails"
  s.add_dependency 'sass-rails'
	s.add_dependency 'browser-timezone-rails', '~> 1.1'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "timecop"
  s.add_development_dependency "spring-commands-rspec"
  s.add_development_dependency "therubyracer"
  s.add_development_dependency "uglifier"
  s.add_development_dependency "thin"
end
