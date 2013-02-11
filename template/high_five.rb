HighFive::Config.configure do |config|
  config.root = File.join(File.basename(__FILE__), '..')
  config.destination = "www"

  # This will add the resources folder (stylesheets etc.) 
  # config.assets "resources"

  config.platform :ios do |ios|
    ios.assets "resources/ios"
    ios.destination "www-ios"
  end

  config.platform :android do |android|
    android.assets "resources/android"
    android.destination "www-android"
  end


end
