# -*- encoding: utf-8 -*-
# stub: ruflet_rails 0.0.23 ruby lib

Gem::Specification.new do |s|
  s.name = "ruflet_rails".freeze
  s.version = "0.0.23".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Adam Moussa Ali".freeze]
  s.date = "1980-01-02"
  s.description = "Build cross-platform mobile and desktop apps with Ruby on Rails using Ruflet.".freeze
  s.email = ["adammusaaly@gmail.com".freeze]
  s.homepage = "https://github.com/AdamMusa/ruflet/tree/main/packages/ruflet_rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "4.0.11".freeze
  s.summary = "Rails integration for Ruflet.".freeze

  s.installed_by_version = "4.0.11".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<rails>.freeze, [">= 7.0".freeze])
  s.add_runtime_dependency(%q<ruflet>.freeze, [">= 0.0.23".freeze])
  s.add_runtime_dependency(%q<ruflet_core>.freeze, [">= 0.0.23".freeze])
  s.add_runtime_dependency(%q<ruflet_server>.freeze, [">= 0.0.23".freeze])
end
