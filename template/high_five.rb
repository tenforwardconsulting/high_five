HighFive::Config.configure do |config|
  config.root = File.join(File.basename(__FILE__), '..')
  config.index = "index.html"
  config.destination = "www"

  config.javascripts "app"
  config.assets "resources"

  config.platform :ios do |ios|
    ios.javascripts "js/cordova-ios-2.3.0.js"
    ios.stylesheets "resources/css/"
  end


end
