require 'fileutils'
module HighFive
  module InitTask

    def init_task
      FileUtils.mkdir_p(File.join("config", "high_five"))
      template_file File.join("config", "high_five.rb"), "high_five.rb"
      template_file File.join("config", "high_five", "high_five.html.erb"), "index.html.erb"
      template_file File.join("config", "high_five", "app-common.js"), "app-common.js"

      #TODO make this a CLI argument
      platforms = ["android", "ios"]
      platforms.each do |platform|
        template_file File.join("config", "high_five","app-#{platform}.js"), "app-platform.js"
      end
    end
    
    private
    def template_file (destination, template)
      if (!File.exists?(destination))
        say "Creating #{destination}"
        FileUtils.cp File.join(File.dirname(__FILE__), "..", "..", "template", template), destination
      end
    end
  end
end
