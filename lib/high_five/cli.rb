require 'thor'
require 'high_five/deploy_task'
require 'high_five/init_task'
require 'high_five/config'

module HighFive
  class Cli < Thor
    include Thor::Actions
    include HighFive::DeployTask
    include HighFive::InitTask

    # source root path for Thor::Actions commands
    source_root(HighFive::TEMPLATE_PATH)

    desc "deploy", "Deploy the app for a specific platform in a specific environment"
    method_option :platform, :aliases => "-p", :desc => "Platform [ios|android|web]", :default => "ios"
    method_option :environment, :aliases => "-e", :desc => "Environemnt [production|development]", :default => "development"
    method_option :compress, :aliases => '-c', :desc => "Compress javascript [true]", :default => false
    method_option :weinre_url, :aliases => '-w', :desc => "Enter your Weinre server-url including port", :default => false
    method_option :"copy-files", :aliases => '-f', :desc => "Copy files to eclipse/xcode directory", :default => false
    def deploy
      deploy_task
    end

    desc "init", "Initialize the high_five configuration in the current working directory"
    def init
      init_task
    end

    def initialize(args=[], options={}, config={})
      super(args, options, config)

      # Don't load config if user is doing >hi5 init
      unless config[:current_task][:name] == "init"
        self.source_paths << File.join(base_config.root)
      end
      # HighFive::Cli.source_root(File.join(base_config.root))
    end


    private

    def base_config
      begin 
        @base_config ||= HighFive::Config.load
      rescue StandardError => e
        say e.message, :red
        exit
      end
    end
  end
end
