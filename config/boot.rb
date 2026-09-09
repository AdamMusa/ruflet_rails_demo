ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
ENV["PORT"] ||= "3030"

require "bundler/setup" # Set up gems listed in the Gemfile.
