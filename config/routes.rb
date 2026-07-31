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

  # HTML DSL native app (Ruflet::Rails.html_app): screens rendered as markup,
  # compiled into real native controls.
  scope :native do
    get "", to: "native#home", as: :native_home
    get "counter", to: "native#counter", as: :native_counter
    post "counter/increment", to: "native#counter_increment", as: :native_counter_increment
    post "counter/decrement", to: "native#counter_decrement", as: :native_counter_decrement
    get "form", to: "native#form", as: :native_form
    post "form", to: "native#form_submit"
    get "widgets", to: "native#widgets", as: :native_widgets
    get "device", to: "native#device", as: :native_device
    get "device/:feature", to: "native#device_feature", as: :native_device_feature
  end

  # A small WhatsApp clone, entirely in the HTML DSL.
  scope :wa do
    get "", to: "whatsapp#index", as: :whatsapp
    get "status", to: "whatsapp#status", as: :whatsapp_status
    get "calls", to: "whatsapp#calls", as: :whatsapp_calls
    get "c/:id", to: "whatsapp#show", as: :whatsapp_conversation
    post "c/:id", to: "whatsapp#create_message", as: :whatsapp_messages
  end

  # Native clients (Ruflet Explorer, or a built mobile/desktop app) connect
  # here. There is no Ruflet app file: the whole UI is the ERB under
  # app/views/native, and this block only says which screen to start on.
  match "/ws", to: Ruflet::Rails.native { |page|
    page.padding = 0
    Ruflet::Rails.erb_to_native(
      page,
      start_url: "#{Ruflet::Rails.backend_url}/native",
      title: "Ruflet Native"
    )
  }, via: :all
end
