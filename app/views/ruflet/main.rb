# frozen_string_literal: true

require "ruflet_rails"

Ruflet.run do |page|
  backend_url = Ruflet::Rails.backend_url
  page.padding = 0
  # Passing a title opts the root screen into native chrome immediately, so the
  # AppBar is painted before the page loads and the loading shimmer stays inside
  # the WebView body (not over the whole screen). The home page's
  # `ruflet_appbar "Demo"` declaration then refines this same AppBar in place.
  Ruflet::Rails.native_app(
    page,
    start_url: "#{backend_url}/",
    title: "Demo",
  
  )
end
