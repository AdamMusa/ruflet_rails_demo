# frozen_string_literal: true

# What one counter tap actually costs on the wire.
#
#   bin/rails runner script/tap_cost.rb

require "ruflet_rails"

sent = []
page = Ruflet::Page.new(session_id: "cost", client_details: {},
                        sender: ->(action, payload) { sent << [action, payload] })

app = Ruflet::Rails.erb_to_native(page, start_url: "http://localhost/native/counter")

def control_count(node)
  case node
  when Ruflet::Control
    1 + node.props.values.sum { |v| control_count(v) } + node.children.sum { |c| control_count(c) }
  when Array then node.sum { |v| control_count(v) }
  else 0
  end
end

def payload_bytes(payload)
  Ruflet::WireCodec.pack(payload).bytesize
rescue StandardError
  JSON.generate(payload).bytesize
end

puts "initial screen: #{control_count(page.views.last)} controls"
sent.clear

# One tap on "Up": the button's on-click posts, Rails redirects, the fetcher
# follows it, and the screen re-renders in place.
button = nil
walk = lambda do |node|
  case node
  when Ruflet::Control
    button ||= node if node.type.include?("button") && node.props["content"].to_s.empty? == false
    node.props.each_value { |v| walk.call(v) }
    node.children.each { |c| walk.call(c) }
  when Array then node.each { |v| walk.call(v) }
  end
end
walk.call(page.views.last)

app.action(method: "post", url: "/native/counter/increment")

total = sent.sum { |(_action, payload)| payload_bytes(payload) }
controls = sent.sum do |(_action, payload)|
  payload.is_a?(Hash) ? control_count(payload.values) : 0
end

puts
puts "one tap sent #{sent.length} message(s), #{total} bytes"
sent.each do |action, payload|
  keys = payload.is_a?(Hash) ? payload.keys.inspect : payload.class.to_s
  puts format("  action %-2s %6d bytes  %s", action.to_s, payload_bytes(payload), keys)
end
puts
puts "…to change one number from #{ENV.fetch('FROM', '?')} to the next."
