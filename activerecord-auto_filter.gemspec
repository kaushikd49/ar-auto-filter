# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord-auto_filter/version'

Gem::Specification.new do |gem|
  gem.name          = "activerecord-auto_filter"
  gem.version       = Activerecord::AutoFilter::VERSION
  gem.authors       = ["kaushik"]
  gem.email         = ["kaushikd49@gmail.com"]
  gem.description   = %q{Configuration based condition building and inclusion handling extension for ActiveRecord::Base}
  gem.summary       = %q{Inclusions and where-condition building extension for ActiveRecord}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "activerecord"
  gem.add_development_dependency "rake"
end
