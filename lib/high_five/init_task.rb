require 'fileutils'
module HighFive
  module InitTask

    def init_task
      FileUtils.mkdir_p(File.join("config", "high_five"))
      conf = File.join("config", "high_five.rb")
      if (!File.exists?(conf))
        say "Creating #{conf}"
        FileUtils.cp File.join(File.dirname(__FILE__), "..", "..", "template", "high_five.rb"), conf
      end
      index = File.join("config", "high_five", "high_five.html.erb")
      if (!File.exists?(index))
        say "Creating #{index}"
        FileUtils.cp File.join(File.dirname(__FILE__), "..", "..", "template", "index.html.erb"), index
      end
      #TODO make this a CLI argument
      platforms = ["common", "ios"]
      platforms.each do |platform|
        platform_js = File.join("config", "high_five","app-#{platform}.js")
        if (!File.exists?(platform_js))
          say "Creating #{platform_js}"
          FileUtils.cp File.join(File.dirname(__FILE__), "..", "..", "template", "app.js"), platform_js
        end
      end
    end

  end
end
