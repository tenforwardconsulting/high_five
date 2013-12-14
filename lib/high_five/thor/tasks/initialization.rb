require 'fileutils'
module HighFive
  module Thor
    module Tasks
      class Initialization < ::HighFive::Thor::Task
        include ::Thor::Actions
        default_task :init

        desc "init", "Initialize the high_five configuration in the current working directory"
        def init
          self.destination_root = Dir.pwd
          self.source_paths << HighFive::TEMPLATE_PATH

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
  end
end
