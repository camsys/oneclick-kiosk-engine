$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kiosk/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kiosk"
  s.version     = Kiosk::VERSION
  s.authors     = ["Benjamin Haas"]
  s.email       = ["benjamin.haas@controlgroup.com"]
  s.homepage    = "https://github.com/camsys/oneclick-kiosk-engine"
  s.summary     = "One-Click Kiosk Engine."
  s.description = "One-Click Kiosk Engine."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "3.2.14"

  s.add_development_dependency "sqlite3"
end
