# frozen_string_literal: true

# "Every Ruflet feature reachable from ERB" made checkable: take every control
# in the registry and try to build it from markup through the HTML DSL.
#
#   bin/rails runner script/dsl_coverage.rb

require "ruflet_rails"

class NullHandlers
  def navigate(*) = nil
  def action(**) = nil
  def submit_form(*) = nil
  def field_changed(*) = nil
  def service(*) = nil
  def control_event(*) = nil
end

CLASS_MAP = Ruflet::UI::ControlFactory::CLASS_MAP
registry = CLASS_MAP.keys.map(&:to_s).uniq.sort

helpers = Ruflet::Rails::HtmlDsl::ViewHelpers.instance_methods(false).map(&:to_s).to_set
service_tags = Ruflet::Rails::HtmlDsl::Transformer::SERVICE_TAGS.to_set

reachable = []
unreachable = []

# A control that answers "I need a title/content/icon" has been routed
# correctly — the DSL reached it and the control validated its own props. That
# is reachable. Only an unroutable tag or an unexpected crash is a real gap.
NEEDS_PROPS = /\A(?:<[^>]+>\s*)?\S+ (?:requires|content is required)|missing keyword|must use a known icon/
needs_props = []

# Some tags need a particular child before they build anything: <tabs> is a
# strip of <tab>s, and a bare one is legitimately empty.
CHILDREN = {
  "tabs" => '<tab label="One"><text>a</text></tab><tab label="Two"><text>b</text></tab>',
  "cupertino_action_sheet" => '<cupertino-action-sheet-action><text>a</text></cupertino-action-sheet-action>'
}.freeze

registry.each do |type|
  tag = type.tr("_", "-")
  inner = CHILDREN.fetch(type, "<text>content</text>")
  html = "<#{tag}>#{inner}</#{tag}>"
  result = Ruflet::Rails::HtmlDsl::Transformer.new(handlers: NullHandlers.new).transform(html)
  # Screen chrome never lands in the body: <appbar> becomes the view's AppBar,
  # <fab> its floating button, <bottom-nav> its navigation bar. Reached is
  # reached, wherever the transformer put it.
  controls = Array(result.controls) + Array(result.services) +
             [result.appbar, result.fab, result.bottom_nav].compact
  degraded = controls.any? do |control|
    props = control.respond_to?(:props) ? control.props : {}
    (props["value"] || props[:value]).to_s.start_with?("⚠")
  end

  if controls.empty? || degraded
    reason = if degraded
               controls.map { |c| (c.respond_to?(:props) ? c.props : {}) }
                       .map { |p| (p["value"] || p[:value]).to_s }
                       .find { |v| v.start_with?("⚠") }.to_s.sub(/\A⚠ /, "")
             else
               "no control"
             end
    if reason =~ NEEDS_PROPS
      needs_props << type
    else
      unreachable << [type, reason]
    end
  else
    reachable << type
  end
rescue StandardError => e
  unreachable << [type, "#{e.class}: #{e.message}"]
end

named_helper = registry.select { |type| helpers.include?(type) || helpers.include?(type.tr("-", "_")) }

puts "registry controls:        #{registry.size}"
puts "build from bare markup:   #{reachable.size}"
puts "routed, need own props:   #{needs_props.size}   (control validated itself)"
puts "with a named ERB helper:  #{named_helper.size}"
puts "service tags:             #{service_tags.size}"
puts
if unreachable.any?
  puts "UNREACHABLE (#{unreachable.size}):"
  unreachable.each { |type, why| puts format("  %-32s %s", type, why) }
else
  puts "every registry control builds from markup"
end
