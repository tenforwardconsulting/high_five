require 'fileutils'
module HighFive
  module InitTask
    def self.included(mod) 
      mod.class_eval do

        desc "init", "Initialize the high_five configuration in the current working directory"
        def init
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


      end #end class_eval
    end
  end
end
