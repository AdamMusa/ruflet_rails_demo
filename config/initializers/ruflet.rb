# frozen_string_literal: true

Ruflet::Rails.configure do |config|
  config.backend_url = ENV.fetch("RUFLET_BACKEND_URL", "http://localhost:3000")
  config.app_name = "Ruflet Rails Demo"
end
