module HighFive
  module AndroidTasks
    desc "debug", "Deploy the app for a specific platform in a specific environment"
    def debug
      self.destination_root = HighFive::ROOT
      puts "Debugy"

    end
  end
end
