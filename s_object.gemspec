# -*- encoding: utf-8 -*-
require File.expand_path('../lib/s_object/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Strueder"]
  gem.email         = ["mikezter@gmail.com"]
  gem.description   = %q{Provides database.com access to Salesforce SObjects.}
  gem.summary       = %q{Provides database.com access to Salesforce SObjects.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "s_object"
  gem.require_paths = ["lib"]
  gem.version       = SObject::VERSION

  gem.add_dependency "typhoeus"
  gem.add_dependency "json"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "factory_girl", "< 3"
  gem.add_development_dependency 'uuid'

end
