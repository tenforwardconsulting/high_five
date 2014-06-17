require 'webrick'
module HighFive
  module Thor
    module Tasks
      class Development < ::HighFive::Thor::Task
        include ::Thor::Actions
        
        desc "server", "Run a web server for a specific environment or path"
        method_option :platform, :aliases => "-e", :desc => "Environemnt [production|development]", :default => "development"
        method_option :platform_path, :desc => "Path to ios or android directory for the platform we want to serve"
        def server(platform="web")
          root = nil
          if options[:platform_path]
            [File.join(options[:platform_path], 'www'), File.join(options[:platform_path], 'assets', 'www')].each do |path|
              if File.exist? path
                root = path
                break
              end
            end
          else
            root = base_config.build_platform_config(platform).destination_root
          end

          puts "Starting server with root=#{root}"

          server = WEBrick::HTTPServer.new(:Port => 3000, :DocumentRoot => root)
          trap 'INT' do server.shutdown end
          server.start
        end
      end
    end
  end
end
