HighFive::Config.configure do |config|
  config.root = File.join(File.basename(__FILE__), '..')
  config.destination = "www"

  # This will add the resources folder (stylesheets etc.) 
  # config.assets "resources"

  # config.platform :ios do |ios|
  #   ios.javascripts "js/cordova-ios-2.3.0.js"
  #   ios.stylesheets "resources/css/"
  # end


end
