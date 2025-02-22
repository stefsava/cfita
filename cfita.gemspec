# frozen_string_literal: true
require File.join(__dir__, "lib", "cfita")

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.4'
  s.name        = 'cfita'
  s.version     = Cfita::VERSION
  s.date        = '2025-02-22'
  s.summary     = 'Italian fiscal code checker'
  s.description = 'Controllo codici fiscali italiani'
  s.authors     = ['Stefano Savanelli']
  s.email       = 'stefano@savanelli.it'
  s.homepage    = 'https://rubygems.org/gems/cfita'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`
                    .split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.add_dependency "activesupport", "> 5.0", "< 9.0"
end
