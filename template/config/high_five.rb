HighFive::Config.configure do |config|
  config.app_name = "ExampleApp"
  config.app_id = "com.example.app"

  config.root = File.join(File.dirname(__FILE__), '..')
  # config.destination = "www"

  # This will run cordova prepare in this directory. Will also default your platform destination to cordova/www
  # config.cordova_path "cordova"

  # Uncomment this if you're on windows and having problems with a strange ExecJS RuntimeError
  # config.windows!

  # This will add the resources folder to all platforms (stylesheets etc.)
  # config.assets "resources"

  # Include javascript libraries
  # These get included before everything else in the app, and are *not* minified

  # config.javascripts "http://maps.google.com/maps/api/js?sensor=true"
  # config.javascripts "lib/jquery-min.js"

  # Run `compass compile` in this directory before doing anything
  # config.compass_dir "resources/sass"

  # copy and include these stylesheets in the html
  # config.stylesheets "resources/css/app.css"
  # config.stylesheets "resources/css/jquery-ui.css"

  # Basic key/value settings that will be available to your javascript
  # config.setting base_url: "http://dev.example.com/api" # HighFive.Settings.base_url = "http://dev.example.com/api"

  # Configure plaform specific settings like this
  config.platform :ios do |ios|
    # ios.destination = "www-ios"
    # ios.assets "resources/ios"
  end

  config.platform :android do |android|
    # android.destination = "www-android"
    # android.assets "resources/android"
  end

  config.platform :Web do |web|
    web.destination = "www"
    web.manifest = true #generate app cache manifest (production env only)
    web.dev_index = "index-debug.html" #copy generated index.html to index-debug (development env only)
  end

  # if you need platform-specific javascripts,
  # simply create app-<platform>.js
  # these files are managed by sprockets, and are used to determine the javascript include order

  # Environment support: production/development/etc
  # Environments work just like platforms
  config.environment :development do |development|
    # development.javascripts "lib/some-library-debug-all.js"
    # development.setting base_url: "http://dev.example.com:1234/api/"
  end

  config.environment :production do |production|
    # production.javascripts "lib/some-library-minified.js"
    # production.setting base_url: "http://production.example.com/api/" #these take precedence over the platform overrides
    # production.minify :uglifier # or :yui
  end

  # config.environment :lan do |lan|
    # ip = Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast?}.ip_address
    # lan.setting apiEndpoint: "http://#{ip}:3000"
  # end
end