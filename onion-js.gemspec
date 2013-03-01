# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'onion-js/version'

Gem::Specification.new do |gem|
  gem.name          = "onion-js"
  gem.version       = OnionJs::VERSION
  gem.authors       = ["Mark Evans"]
  gem.email         = ["mark@new-bamboo.co.uk"]
  gem.description   = %q{Onion JS. Brings tears to your eyes.}
  gem.summary       = %q{Onion JS. Brings tears to your eyes.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
