# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apipie_diff/version"

Gem::Specification.new do |s|
  s.name          = "apipie-diff"
  s.version       = ApipieDiff.version.dup
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Tomáš Strachota"]
  s.email         = "tstrachota@redhat.com"
  s.homepage      = "http://github.com/tstrachota/apipie-diff"
  s.license       = "GPL-3.0"

  s.summary       = %q{Diff tool for ApiPie documentation}

  s.files = Dir['{lib,bin}/**/*', 'LICENSE', 'README*']

  s.extra_rdoc_files = Dir['README*']
  s.require_paths = ["lib"]
  s.executables = ['apipie-diff']

  s.add_dependency 'diffy', '~> 3.2'
  s.add_dependency 'colorize', '~> 0.8'
  s.add_dependency 'clamp', '~> 1.1'
end
