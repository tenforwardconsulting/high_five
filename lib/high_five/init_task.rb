require 'fileutils'
module HighFive
  module InitTask

    def init_task
      FileUtils.mkdir_p("config")
      conf = File.join("config", "high_five.rb")
      if (!File.exists?(conf))
        say "Creating #{conf}"
        FileUtils.cp File.join(File.dirname(__FILE__), "..", "..", "template", "high_five.rb"), conf
      end
      platforms = ["android", "ios", "web"]
      platforms.each do |platform|
        platform_js = "app-#{platform}.js"
        if (!File.exists?(platform_js))
          say "Creating #{platform_js}"
          FileUtils.cp File.join(File.dirname(__FILE__), "..", "..", "template", "app.js"), platform_js
        end
      end
    end

  end
end
