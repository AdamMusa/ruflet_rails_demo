# frozen_string_literal: true

# Renders every native screen through the real erb_to_native pipeline
# (TemplateSource -> Parser -> Transformer) and reports what fails.
#
#   bin/rails runner script/compile_screens.rb

require "ruflet_rails"

FEATURES = NativeController::DEVICE_FEATURES.keys

URLS = [
  "/native", "/native/counter", "/native/form", "/native/widgets", "/native/device",
  # every feature screen, from the controller's own list, so a screen added
  # there cannot slip past this sweep
  *FEATURES.map { |slug| "/native/device_feature/#{slug}" },
  "/whatsapp", "/whatsapp/status", "/whatsapp/calls", "/whatsapp/show/ada"
].freeze

# Handlers only record; nothing here needs a live page or socket.
class RecordingHandlers
  def navigate(*) = nil
  def action(**) = nil
  def submit_form(*) = nil
  def field_changed(*) = nil
  def service(*) = nil
  def control_event(*) = nil
end

fetcher = Ruflet::Rails::HtmlDsl::TemplateSource.new
host = "http://localhost"
failures = []
totals = Hash.new(0)

URLS.each do |path|
  url = "#{host}#{path}"
  response = fetcher.fetch(url)
  if response.body.to_s.include?("Screen failed") || response.body.to_s.include?("No screen for")
    failures << [path, response.body.to_s[%r{<h3>([^<]*)</h3>}, 1] || "screen failed"]
    next
  end

  result = Ruflet::Rails::HtmlDsl::Transformer
           .new(handlers: RecordingHandlers.new)
           .transform(response.body)
  controls = Array(result.controls)

  # Walk the whole tree: the transformer degrades a bad element into a red
  # "⚠ <tag> …" text instead of raising, so a screen can "compile" while
  # silently losing controls. Those are the real failures.
  deep = 0
  warnings = []
  visit = lambda do |control|
    deep += 1
    props = control.respond_to?(:props) ? control.props : {}
    value = props["value"] || props[:value]
    warnings << value.to_s if value.is_a?(String) && value.start_with?("⚠")
    props.each_value do |prop|
      Array(prop).each { |child| visit.call(child) if child.respond_to?(:props) }
    end
    control.children.each { |child| visit.call(child) } if control.respond_to?(:children)
  end
  controls.each { |control| visit.call(control) }

  totals[:screens] += 1
  totals[:controls] += deep
  totals[:services] += Array(result.services).size
  totals[:warnings] += warnings.size

  if controls.empty?
    failures << [path, "no controls produced"]
  elsif warnings.any?
    failures << [path, "#{warnings.size} degraded: #{warnings.uniq.first(3).join(' | ')}"]
  else
    puts format("  ok  %-34s %3d controls, %d services%s", path, deep,
                Array(result.services).size, result.appbar ? ", appbar" : "")
  end
rescue StandardError => e
  failures << [path, "#{e.class}: #{e.message}"]
end

puts
puts format("%d/%d screens compiled, %d controls, %d services, %d degraded elements",
            totals[:screens], URLS.size, totals[:controls], totals[:services], totals[:warnings])

if failures.any?
  puts "\nFAILURES (#{failures.size}):"
  failures.each { |path, reason| puts format("  %-34s %s", path, reason) }
  exit 1
end
puts "\nALL SCREENS COMPILED"
