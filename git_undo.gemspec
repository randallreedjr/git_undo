# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_undo/version'

Gem::Specification.new do |spec|
  spec.name          = "git_undo"
  spec.version       = GitUndo::VERSION
  spec.authors       = ["Randall Reed, Jr."]
  spec.email         = ["randallreedjr@gmail.com"]

  spec.summary       = %q{Undo last git command}
  spec.description   = %q{Command line utility to read from bash history, find last git command, and output command to undo that operation.}
  spec.homepage      = "https://github.com/randallreedjr/git_undo"
  spec.license       = "MIT"

  spec.files         = ['lib/git_undo/git_manager.rb','config/environment.rb']
  spec.executables   << 'gitundo'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
