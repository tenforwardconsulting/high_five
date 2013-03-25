require 'fileutils'
module HighFive
  module InitTask

    def init_task
      self.destination_root = HighFive::ROOT

      inside "config" do
        template("high_five.rb")
        inside "high_five" do
          copy_file "index.html.erb", :skip => true
          copy_file "app-common.js", :skip => true

          #TODO make this a CLI argument
          platforms = ["android", "ios"]
          platforms.each do |platform|
            copy_file "app-platform.js", "app-#{platform}.js", :skip => true
          end
        end
      end
    end
  end
end
