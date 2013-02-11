require 'thor'
require 'high_five/deploy_task'
require 'high_five/init_task'
require 'high_five/config'

module HighFive
  class Cli < Thor
    include Thor::Actions
    include HighFive::DeployTask
    include HighFive::InitTask

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

    def self.source_root 
      File.join(config.root)
    end

    private

    def config
      @config ||= HighFive::Config.load
    end
  end
end
