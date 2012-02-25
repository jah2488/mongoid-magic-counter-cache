# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongoid_counter_cache/version"

Gem::Specification.new do |s|
  s.name        = "mongoid_counter_cache"
  s.version     = MongoidCounterCache::VERSION
  s.authors     = ["Justin Herrick"]
  s.email       = ["justin@justinherrick.com"]
  s.homepage    = "https://github.com/jah2488/mongoid-counter-cache"
  s.summary     = %q{Setup Counter Caches in Mongoid Documents}
  s.description = %q{A quick and easy way to add counter cache functionality to model/document associations in Mongoid}

  s.rubyforge_project = "mongoid_counter_cache"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
