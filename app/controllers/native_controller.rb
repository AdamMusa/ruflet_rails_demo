# frozen_string_literal: true

# Screens for the native app (Ruflet::Rails.html_app): every view here is a
# Rails view that the Ruflet runtime renders as real native controls.
class NativeController < ApplicationController
  layout "native"

  DEVICE_FEATURES = {
    "clipboard" => "Clipboard", "share" => "Share", "flashlight" => "Flashlight",
    "screen_brightness" => "Screen brightness", "battery" => "Battery",
    "connectivity" => "Connectivity", "location" => "Geolocator",
    "permissions" => "Permission handler", "file_picker" => "File picker",
    "secure_storage" => "Secure storage", "preferences" => "Shared preferences",
    "accessibility" => "Semantics service", "audio_recorder" => "Audio recorder",
    "storage_paths" => "Storage paths", "accelerometer" => "Accelerometer",
    "gyroscope" => "Gyroscope", "user_accelerometer" => "User accelerometer",
    "magnetometer" => "Magnetometer", "barometer" => "Barometer",
    "spinkit" => "SpinKit", "charts" => "Charts",
    "code_editor" => "Code editor", "audio" => "Audio", "video" => "Video",
    "rive" => "Rive", "camera" => "Camera", "map" => "Map", "webview" => "WebView"
  }.freeze

  def home; end

  def counter
    @count = session[:count] ||= 0
  end

  # A tap runs the method and the screen re-renders; there is nothing to
  # redirect to and no second fetch to avoid.
  def counter_increment
    session[:count] = (session[:count] || 0) + 1
  end

  def counter_decrement
    session[:count] = (session[:count] || 0) - 1
  end

  def form; end

  def form_submit
    @submitted = {
      "Name" => params[:name].presence || "—",
      "Email" => params[:email].presence || "—",
      "Language" => params[:locale].presence || "—",
      "Newsletter" => params[:newsletter].to_s == "true" ? "Yes" : "No"
    }
    render :form_result
  end

  def widgets; end
  def device; end

  def device_feature
    @feature = params[:id].to_s
    raise ActionController::RoutingError, "Unknown native feature" unless DEVICE_FEATURES.key?(@feature)

    @feature_title = DEVICE_FEATURES.fetch(@feature)
  end

end
