lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jass/rollup/esm/version'

Gem::Specification.new do |s|
  s.name          = 'jass-rollup-esm'
  s.version       = Jass::Rollup::ESM::VERSION
  s.date          = '2021-09-17'
  s.authors       = ['Matthias Grosser']
  s.email         = ['mtgrosser@gmx.net']
  s.license       = 'MIT'

  s.summary       = 'Compile Node modules to ESM with Sprockets'
  s.homepage      = 'https://github.com/mtgrosser/jass-rollup-esm'

  s.files = ['LICENSE', 'README.md'] + Dir['lib/**/*.rb']
  
  s.required_ruby_version = '>= 2.3.0'
  
  s.add_dependency 'jass-core'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'minitest'
end
