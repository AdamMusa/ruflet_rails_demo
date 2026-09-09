# Ruflet Rails Demo

Rails ERB views rendered as **real native controls** — no WebView, no Dart, and
no standalone Ruflet app. Every screen is an ordinary Rails route: routing runs,
the controller runs (params, `before_action`s, `@ivars`, saving a form), and the
ERB view is compiled into a native control tree by `Ruflet::Rails.erb_to_native`.

There is no Ruflet app file at all — the UI *is* the ERB.

```
app/views/native/**.html.erb     the native screens (ERB -> native controls)
app/views/whatsapp/**.html.erb   a small chat app in the same DSL
config/routes.rb                 plain Rails routes + the /ws mount, which
                                 names the start screen in a block
config/initializers/ruflet.rb    app name, services, extensions, build artwork
```

## Run

```bash
bin/rails server -b 0.0.0.0
```

The server defaults to port 3030, including when started with `bin/dev`.

Connect Ruflet Explorer or `ruflet_app` to `http://127.0.0.1:3030`. The same
URLs also render as ordinary HTML in a browser, which is what keeps the screens
inspectable.

## Open it inside a normal Ruflet app

The `RufletApp/demo/hybride.rb` example combines two sections in one client:
local Ruflet controls and this server-driven Rails UI.

Keep this Rails server running, then start the hybrid app from another terminal:

```bash
cd ../../RufletApp/demo
../../FlutterApp/ruflet/packages/ruflet/bin/ruflet run hybride
```

Set `RAILS_URL` in `hybride.rb` to `http://127.0.0.1:3030`, then open the Rails
tab to display this app through `ruflet_app`. On a physical
phone, replace `127.0.0.1` in `hybride.rb` with the computer's LAN address.

## Writing a screen

Helpers emit the HTML DSL; classes are Tailwind-flavoured and map to native
styling. Links navigate, forms POST back through the controller.

```erb
<%= appbar "Counter" %>
<%= column class: "p-6 gap-4 items-center" do %>
  <%= text @count, class: "text-5xl font-bold" %>
  <%= row class: "gap-3" do %>
    <%= button "Up", variant: "filled", icon: "add", on_click: native_counter_increment_path %>
  <% end %>
<% end %>
```

Platform services are declared the same way — drop one on the screen and point
a control at it:

```erb
<%= battery on_state_change_service: "battery", on_state_change_result_target: "status" %>
<%= text "-", id: "status" %>
<%= button "Refresh", service: "battery", result_target: "status", on_load: true %>
```

## Checking the DSL

Two scripts keep "every Ruflet feature is reachable from ERB" honest.

```bash
bin/rails runner script/compile_screens.rb
```

Renders every screen through the real pipeline (RackFetcher → Parser →
Transformer) and fails if any element silently degraded into a placeholder — the
transformer turns a bad element into red `⚠` text rather than raising, so a
screen can otherwise "compile" while quietly losing controls.

```bash
bin/rails runner script/dsl_coverage.rb
```

Walks the whole control registry and reports what markup can reach.

Current state: **41/41 screens, 707 controls, 22 services, 0 degraded**, and all
329 registry controls reachable from markup.

## Gems

Local path gems from `../../FlutterApp/ruflet/packages/*` — `ruflet_core`,
`ruflet_server`, `ruflet`, and `ruflet_rails`, which now ships the HTML DSL
(`lib/ruflet/rails/html_dsl/`).
