# frozen_string_literal: true

Ruflet::Rails.configure do |config|
  # Keep this URL aligned with the Rails server. RufletApp/demo/hybride.rb uses
  # the same base URL to mount this server-driven section inside a normal app.
  config.backend_url = ENV.fetch("RUFLET_BACKEND_URL", "http://127.0.0.1:3030")
  config.app_name = "Ruflet Rails Demo"

  # Build artwork. In a Rails app this initializer is the source of truth —
  # the build task serializes it into the ruflet.yaml the CLI wants, so the
  # project keeps no yaml of its own.
  config.splash_screen = Rails.root.join("app/assets/images/splash.png")
  config.icon_launcher = Rails.root.join("app/assets/images/icon.png")

  # Native capabilities used by the ERB device gallery. These declarations
  # drive the generated iOS/Android permission metadata.
  config.services = [
    { camera: { description: "Capture photos in the ERB-native camera example." } },
    { microphone: { description: "Record audio in the ERB-native recorder example." } },
    { location: { description: "Read location in the ERB-native device examples." } },
    { motion: { description: "Read accelerometer, gyroscope, magnetometer, and barometer data." } }
  ]

  # Optional client controls rendered directly by app/views/native/*.erb.
  config.extensions = %w[
    audio
    audio_recorder
    camera
    charts
    code_editor
    flashlight
    geolocator
    map
    permission_handler
    rive
    secure_storage
    spinkit
    video
    webview
  ]
end
