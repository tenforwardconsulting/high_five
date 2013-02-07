module HighFive
  class Init < Thor
    FileUtils.mkdir_p("config")
    conf = File.join("config", "high_five.rb")
    if (!File.exists?(conf))
      say "Creating #{conf}"
      File.cp File.join(File.basename(__FILE__), "..", "..", "templates", "high_five.rb"), conf
    end
  end
end
