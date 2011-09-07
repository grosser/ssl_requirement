# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ssl_requirement/version"

Gem::Specification.new do |s|
  s.name                  = "dawanda-ssl_requirement"
  s.version               = SslRequirement::Version::STRING
  s.platform              = Gem::Platform::RUBY
  s.authors               = ["DaWanda"]
  s.email                 = ["cupcakes@dawanda.com"]
  s.homepage              = "http://rubygems.org/gems/dawanda-ssl_requirement"
  s.summary               = "A fork to add some cool options to ssl_requirement"
  s.description           = s.summary
  s.license               = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "actionpack", ENV["RAILS"]


  s.add_development_dependency "redgreen"
  s.add_development_dependency "rake"
end
