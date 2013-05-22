require 'thor'
require 'high_five/deploy_task'
require 'high_five/init_task'
require 'high_five/android_tasks'
require 'high_five/config'

module HighFive
  class Cli < Thor
    include Thor::Actions
    include HighFive::InitTask
    include HighFive::DeployTask
    include HighFive::AndroidTasks
    # source root path for Thor::Actions commands

    class_option :version, type: :boolean, desc: "Print version and ext", aliases: "-v"
    def initialize(*args)
      super
      if options[:version]
        puts "HighFive #{HighFive::VERSION}" 
        Process.exit(0)
      end
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