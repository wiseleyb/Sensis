# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sensis/version"

Gem::Specification.new do |s|
  s.name        = "sensis"
  s.version     = Sensis::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Wiseley"]
  s.email       = ["wiseley@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby gem for Sensis search api}
  s.description = %q{More on Sensis search api http://developers.sensis.com.au/}

  s.rubyforge_project = "sensis"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency "rspec-rails"  
  s.add_development_dependency "rspec-core"
  # s.add_development_dependency "activerecord", '3.0.5' # for creating fake models for the API
  # s.add_development_dependency "sqlite3"
  # s.add_development_dependency "database_cleaner"
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "json"
  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "rcov"
  s.add_development_dependency "tzinfo"
end
