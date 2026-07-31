# frozen_string_literal: true

# Proves the two properties the ERB path depends on:
#
#   1. screens are fetched in-process (no HTTP socket), so they are fast
#   2. each WebSocket session owns its fetcher, so Rails session state is
#      per-session and nothing is lost between screens
#
#   bin/rails runner script/fetch_benchmark.rb

require "ruflet_rails"

# benchmark left the default gems in Ruby 4.0; the monotonic clock is enough.
def elapsed
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  yield
  Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
end

class NullHandlers
  def navigate(*) = nil
  def action(**) = nil
  def submit_form(*) = nil
  def field_changed(*) = nil
  def service(*) = nil
  def control_event(*) = nil
end

HOST = "http://localhost"
T = Ruflet::Rails::HtmlDsl::Transformer

# --- 1. cost of a screen ----------------------------------------------------
fetcher = Ruflet::Rails::HtmlDsl::RackFetcher.new
%w[/native /native/widgets /wa].each do |path|
  url = "#{HOST}#{path}"
  fetcher.fetch(:get, url) # warm the controller/view cache

  runs = 20
  fetch_s = elapsed { runs.times { fetcher.fetch(:get, url) } } / runs
  body = fetcher.fetch(:get, url).body
  transform_s = elapsed { runs.times { T.new(handlers: NullHandlers.new).transform(body) } } / runs

  puts format("%-18s fetch %5.2f ms   transform %5.2f ms   total %5.2f ms",
              path, fetch_s * 1000, transform_s * 1000, (fetch_s + transform_s) * 1000)
end

# --- 2. per-session isolation ----------------------------------------------
# Two fetchers stand in for two connected clients. Each POSTs the counter;
# neither should see the other's count.
a = Ruflet::Rails::HtmlDsl::RackFetcher.new
b = Ruflet::Rails::HtmlDsl::RackFetcher.new

count = lambda do |fetcher|
  body = fetcher.fetch(:get, "#{HOST}/native/counter").body
  body[/<text[^>]*class="text-5xl[^"]*"[^>]*>(-?\d+)</, 1] || body[/>(-?\d+)</, 1]
end

token = lambda do |fetcher|
  fetcher.fetch(:get, "#{HOST}/native/counter").body[/name="csrf-token" content="([^"]+)"/, 1]
end

3.times { a.fetch(:post, "#{HOST}/native/counter/increment", params: { authenticity_token: token.call(a) }) }
1.times { b.fetch(:post, "#{HOST}/native/counter/increment", params: { authenticity_token: token.call(b) }) }

puts
puts "session A count: #{count.call(a)}   (incremented 3x)"
puts "session B count: #{count.call(b)}   (incremented 1x)"
puts(count.call(a) != count.call(b) ? "sessions are independent" : "LEAK: sessions share state")
