require 'fileutils'
module HighFive
  module InitTask

    def init_task
      destination_root = HighFive::ROOT
  
      inside "config" do 
        template("high_five.rb")
      end

      copy_file "index.html.erb", :skip => true

      platforms = ["android", "ios", "web"]

      platforms.each do |platform|
        platform_js = "app-#{platform}.js"
        copy_file "app.js", "app-#{platform}.js", :skip => true
      end
    end
  end
end
