# -*- encoding: utf-8 -*-
# stub: event_aggregator 1.1.5 ruby lib

Gem::Specification.new do |s|
  s.name = "event_aggregator"
  s.version = "1.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Stephan Eriksen"]
  s.date = "2014-03-11"
  s.description = "A simple Ruby event aggregator."
  s.email = ["stephan.n.eriksen@gmail.com"]
  s.homepage = "https://github.com/stephan-nordnes-eriksen/event_aggregator"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Event aggregator for Ruby."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, ["~> 10"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0.0.beta1"])
      s.add_development_dependency(%q<guard-rspec>, [">= 4.2.2", "~> 4.2"])
      s.add_development_dependency(%q<faker>, ["~> 1.2"])
      s.add_development_dependency(%q<coveralls>, ["~> 0.7"])
      s.add_runtime_dependency(%q<thread>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, ["~> 10"])
      s.add_dependency(%q<rspec>, ["~> 3.0.0.beta1"])
      s.add_dependency(%q<guard-rspec>, [">= 4.2.2", "~> 4.2"])
      s.add_dependency(%q<faker>, ["~> 1.2"])
      s.add_dependency(%q<coveralls>, ["~> 0.7"])
      s.add_dependency(%q<thread>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, ["~> 10"])
    s.add_dependency(%q<rspec>, ["~> 3.0.0.beta1"])
    s.add_dependency(%q<guard-rspec>, [">= 4.2.2", "~> 4.2"])
    s.add_dependency(%q<faker>, ["~> 1.2"])
    s.add_dependency(%q<coveralls>, ["~> 0.7"])
    s.add_dependency(%q<thread>, [">= 0"])
  end
end
