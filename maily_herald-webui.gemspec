$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "maily_herald/webui/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "maily_herald-webui"
  s.version     = MailyHerald::Webui::VERSION
  s.authors     = ["Łukasz Jachymczyk"]
  s.email       = ["lukasz@sology.eu"]
  s.homepage    = "https://github.com/Sology/maily_herald-webui"
  s.license     = "LGPL-3.0"
  s.description = s.summary = "Web UI for MailyHerald - Email processing solution for Ruby on Rails applications"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.2.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
end
