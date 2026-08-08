Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "demo#home"

  get "/inbox", to: "demo#inbox"
  get "/settings", to: "demo#settings"
  get "/profile", to: "demo#profile"
  get "/compose", to: "demo#compose"

  # The native app. This is the only route it uses.
  #
  # The screens are the ERB under app/views/native and app/views/whatsapp —
  # the ERB file plays the part a Ruflet Ruby app file plays. They are not
  # routes and are not reachable over HTTP: a tap calls a method on the
  # matching controller directly, inside the WebSocket session, and the
  # template re-renders. Nothing goes through Rails routing or middleware, so
  # there is no request per interaction.
  match "/ws", to: Ruflet::Rails.native { |page|
    page.padding = 0
    Ruflet::Rails.erb_to_native(page, start_url: "/native", title: "Ruflet Native")
  }, via: :all
end
