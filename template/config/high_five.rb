HighFive::Config.configure do |config|
  config.root = File.join(File.dirname(__FILE__), '..')
  config.destination = "www"

  # This will add the resources folder to all platforms (stylesheets etc.) 
  # config.assets "resources"

  # Include javascript libraries
  # These get included before everything else in the app

  # config.javascripts "http://maps.google.com/maps/api/js?sensor=true"
  # config.javascripts "lib/jquery-min.js"

  # Configure plaform specific settings like this
  # config.platform :ios do |ios|
  #   ios.assets "resources/ios"
  #   ios.destination = "www-ios"
  # end

  # if you need platform-specific javascripts, 
  # simply create app-<platform>.js next too app.js


end
