# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-oraclepaas/version"

Gem::Specification.new do |s|
  s.name        = "knife-oraclepaas"
  s.version     = Knife::Oraclepaas::VERSION
  s.platform    = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.authors     = ["Joel Nation"]
  s.email       = ["joel.nation@oracle.com"]
  s.homepage    = "https://github.com/Joelith/knife-cloud-paas"
  s.summary     = "Knife plugin to interact with the Oracle Cloud Platform"
  s.description = s.description

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "knife-cloud"

  %w(rspec-core rspec-expectations rspec-mocks rspec_junit_formatter).each { |gem| s.add_development_dependency gem }
end
