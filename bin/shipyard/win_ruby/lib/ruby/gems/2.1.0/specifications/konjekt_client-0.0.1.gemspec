# -*- encoding: utf-8 -*-
# stub: konjekt_client 0.0.1 ruby lib
# stub: ext/mkrf_conf.rb

Gem::Specification.new do |s|
  s.name = "konjekt_client"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Stephan Nordnes Eriksen"]
  s.date = "2014-08-30"
  s.description = "Runs the file indexer, the server connector and everything that is needed to run our product."
  s.email = ["sne@konjekt.com"]
  s.extensions = ["ext/mkrf_conf.rb"]
  s.files = ["ext/mkrf_conf.rb"]
  s.homepage = "https://konjekt.com"
  s.licenses = ["Copyright (c) 2014 Stephan Nordnes Eriksen - All Rights Reserved"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = "2.2.2"
  s.summary = "The client side of Konjekt"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<event_aggregator>, [">= 1.1.5", "~> 1.1"])
      s.add_runtime_dependency(%q<rb-fsevent>, ["~> 0.9"])
      s.add_runtime_dependency(%q<listen>, ["= 0.7.3"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<geocoder>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<macaddr>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.5"])
      s.add_development_dependency(%q<faker>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<debugger>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, [">= 0"])
    else
      s.add_dependency(%q<event_aggregator>, [">= 1.1.5", "~> 1.1"])
      s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
      s.add_dependency(%q<listen>, ["= 0.7.3"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<geocoder>, ["~> 1.1.0"])
      s.add_dependency(%q<macaddr>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.5"])
      s.add_dependency(%q<faker>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.14"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
      s.add_dependency(%q<debugger>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
    end
  else
    s.add_dependency(%q<event_aggregator>, [">= 1.1.5", "~> 1.1"])
    s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
    s.add_dependency(%q<listen>, ["= 0.7.3"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<geocoder>, ["~> 1.1.0"])
    s.add_dependency(%q<macaddr>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.5"])
    s.add_dependency(%q<faker>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.14"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
    s.add_dependency(%q<debugger>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
  end
end
