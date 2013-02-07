HighFive::Config.configure do |config|
   config.root = File.join(File.basename(__FILE__), '..')
   config.index = "index.html"
end