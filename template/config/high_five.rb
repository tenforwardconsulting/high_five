HighFive::Config.configure do |config|
  config.root = File.join(File.dirname(__FILE__), '..')
  config.destination = "www"

  # This will add the resources folder to all platforms (stylesheets etc.) 
  # config.assets "resources"

  # Include javascript libraries
  # These get included before everything else in the app, and are *not* minified

  # config.javascripts "http://maps.google.com/maps/api/js?sensor=true"
  # config.javascripts "lib/jquery-min.js"

  # Run `compass compile` in this directory before doing anything
  # config.compass "resources/sass"

  # copy and include these stylesheets in the html
  # config.stylesheets "resources/css/app.css"
  # config.stylesheets "resources/css/jquery-ui.css"

  # Basic key/value settings that will be available to your javascript
  # config.setting base_url: "http://dev.example.com/api" # HighFive.settings.base_url = "http://dev.example.com/api"

  # Configure plaform specific settings like this
  # config.platform :ios do |ios|
  #   ios.assets "resources/ios"
  #   ios.destination = "www-ios"
  # end

  # if you need platform-specific javascripts, 
  # simply create app-<platform>.js 
  # these files are managed by sprockets, and are used to determine the javascript include order

  # Environment support: production/development/etc
  # Environments work just like platforms
  # config.environment :production do |prod|
  #   production.javascripts "settings/production.js"
  #   production.setting base_url: "http://production.example.com/api/" #these take precedence over the platform overrides
  # end

end
