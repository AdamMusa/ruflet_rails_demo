module ApplicationHelper
  NATIVE_SERVICE_FEATURES = [
    ["clipboard", "Clipboard", "content_paste"], ["share", "Share", "share"],
    ["flashlight", "Flashlight", "flashlight_on"], ["screen_brightness", "Screen brightness", "brightness_6"],
    ["battery", "Battery", "battery_full"], ["connectivity", "Connectivity", "wifi"],
    ["location", "Geolocator", "my_location"], ["permissions", "Permission handler", "verified_user"],
    ["file_picker", "File picker", "folder_open"], ["secure_storage", "Secure storage", "lock"],
    ["preferences", "Shared preferences", "tune"], ["accessibility", "Semantics service", "record_voice_over"],
    ["audio_recorder", "Audio recorder", "mic"], ["storage_paths", "Storage paths", "folder"],
    ["accelerometer", "Accelerometer", "speed"], ["gyroscope", "Gyroscope", "screen_rotation"],
    ["user_accelerometer", "User accelerometer", "speed"],
    ["magnetometer", "Magnetometer", "explore"], ["barometer", "Barometer", "compress"]
  ].freeze

  NATIVE_EXTENSION_FEATURES = [
    ["spinkit", "SpinKit", "hourglass_top"], ["charts", "Charts", "bar_chart"],
    ["code_editor", "Code editor", "code"], ["audio", "Audio", "headphones"],
    ["video", "Video", "movie"], ["rive", "Rive", "animation"],
    ["camera", "Camera", "photo_camera"], ["map", "Map", "map"],
    ["webview", "WebView", "language"], ["dialog", "Dialog", "chat_bubble"],
    ["bottom_sheet", "Bottom sheet", "expand_less"], ["date_picker", "Date picker", "event"],
    ["time_picker", "Time picker", "schedule"]
  ].freeze

  def native_feature_link(slug, title, icon_name)
    list_tile(
      title: title,
      subtitle: "Open the Ruflet Studio example",
      leading: icon_name,
      trailing: "chevron_right",
      href: "/native/device_feature/#{slug}"
    )
  end

end
