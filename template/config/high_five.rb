HighFive::Config.configure do |config|
  config.app_name = "ExampleApp"
  config.app_id = "com.example.app"

  config.root = File.join(File.dirname(__FILE__), '..')
  # config.destination = "www"

  # This will run cordova prepare in this directory. Will also default your platform destination to cordova/www.
  # config.cordova_path "cordova"

  # Uncomment this if you're on windows and having problems with a strange ExecJS RuntimeError.
  # config.windows!

  # Include assets (images, fonts, etc).
  # This will add the given directory or file to the <destination>/resources directory.
  # e.g.
  # config.assets "resources/images"
  # config.assets "resources/vendor/font-awesome-4.5.0"

  # Include javascript libraries.
  # These get included before everything else in the app and are *not* minified.
  # Make sure you link to the minified versions of your assets if that's what you desire.
  # e.g.
  # config.javascripts "http://maps.google.com/maps/api/js?sensor=true"
  # config.javascripts "resources/vendor/javascripts/jquery-min.js"

  # Include stylesheets.
  # e.g.
  # config.stylesheets "resources/css/app.css"
  # config.stylesheets "resources/css/jquery-ui.css"
  # config.stylesheets "resources/vendor/font-awesome-4.5.0/css/font-awesome.min.css"

  # Run `compass compile` in this directory before doing anything.
  # config.compass_dir "resources/sass"

  # Basic key, value pairs that will be available to your javascript under HighFive.Settings.
  # config.setting apiEndpoint: "http://dev.example.com/api" # HighFive.Settings.apiEndpoint will return "http://dev.example.com/api"

  # ===========================================================================
  # Platforms
  #   Configure plaform specific settings like this.
  #   Make sure config/high_five/app-<platform>.js exists. Put platform specific javascript in there.
  #   See existing files for minimum contents.
  #   Those files are managed by sprockets and are used to determine the javascript include order.
  # ===========================================================================
  config.platform :ios do |ios|
    # ios.destination = "cordova/platforms/ios/www" # Cordova
    # ios.assets "resources/ios"
  end

  config.platform :android do |android|
    # android.destination = "cordova/platforms/android/assets/www" # Cordova
    # android.assets "resources/android"
  end

  config.platform :web do |web|
    web.destination = "www"
    web.setting apiEndpoint: 'http://localhost:3000' # Or however you specify your server's location.
    web.manifest = true # Generate app cache manifest. This is only done when environment is 'production'.
    web.dev_index = "index-debug.html" # Copy generated index.html to index-debug.
  end

  # ===========================================================================
  # Environments
  #   Configure environment specific settings like this.
  #   Environments work just like platforms and allow you to further customize/override settings.
  #   These take precedence over the platform overrides.
  #   e.g.
  #     You can deploy to an iOS device and point the app at your production server.
  #     or deploy to an Android device and point the app at your dev/staging/qa server.
  # ===========================================================================
  config.environment :lan do |lan|
    ip = Socket.ip_address_list.detect { |intf| intf.ipv4? && !intf.ipv4_loopback? && !intf.ipv4_multicast? }.ip_address
    lan.setting apiEndpoint: "http://#{ip}:3000" # Or however you specify your server's location.
    # lan.javascripts "resources/vendor/javascripts/some-library-debug-all.js"
  end

  config.environment :dev do |dev|
    dev.setting apiEndpoint: "http://dev.example.com"
    # dev.javascripts "lib/some-library-minified.js"
  end

  config.environment :production do |production|
    production.setting apiEndpoint: "http://example.com"
    # production.javascripts "lib/some-library-minified.js"
    # production.minify :uglifier # or :yui
  end
end
