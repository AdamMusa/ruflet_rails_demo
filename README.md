# Ruflet Rails Demo

Small Rails app demonstrating `ruflet_rails` NativeApp behavior.

## Run

```bash
cd /Users/macbookpro/Documents/Izeesoft/RailsApp/ruflet_rails_demo
rbenv exec bundle install
PORT=3030 RUFLET_BACKEND_URL=http://localhost:3030 rbenv exec bundle exec rails server -p 3030
```

Open the normal Rails app at:

- http://localhost:3030

Connect Ruflet Explorer to:

- http://localhost:3030/ws

The demo uses local path gems from:

- `/Users/macbookpro/Documents/Izeesoft/FlutterApp/ruflet/packages/ruflet_core`
- `/Users/macbookpro/Documents/Izeesoft/FlutterApp/ruflet/packages/ruflet_server`
- `/Users/macbookpro/Documents/Izeesoft/FlutterApp/ruflet/packages/ruflet`
- `/Users/macbookpro/Documents/Izeesoft/FlutterApp/ruflet/packages/ruflet_rails`

The page bodies are plain Rails ERB rendered in WebViews. Ruflet adds native
screen chrome only where the views declare `data-ruflet-*` attributes.
