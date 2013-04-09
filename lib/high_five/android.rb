module HighFive
  module AndroidTasks
    desc "debugy", "Deploy the app for a specific platform in a specific environment"
    method_option :environment, :aliases => "-e", :desc => "Environemnt [production|development]", :default => "development"
    method_option :compress, :aliases => '-c', :desc => "Compress javascript [true]", :default => false
    method_option :weinre_url, :aliases => '-w', :desc => "Enter your Weinre server-url including port", :default => false
    method_option :"copy-files", :aliases => '-f', :desc => "Copy files to eclipse/xcode directory", :default => false
    def debug
      self.destination_root = HighFive::ROOT

    end
  end
end
