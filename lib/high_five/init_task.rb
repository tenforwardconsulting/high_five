require 'fileutils'
module HighFive
  module InitTask
    desc "init", "Initialize the high_five configuration in the current working directory"
    def init
      FileUtils.mkdir_p("config")
      conf = File.join("config", "high_five.rb")
      if (!File.exists?(conf))
        say "Creating #{conf}"
        File.cp File.join(File.basename(__FILE__), "..", "..", "templates", "high_five.rb"), conf
      end
    end
  end
end
