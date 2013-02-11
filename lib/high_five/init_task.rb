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
    end

  end
end
