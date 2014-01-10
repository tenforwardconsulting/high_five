require "thor/runner"
require 'high_five/thor/task'
require 'high_five/thor/tasks'

module HighFive
  module Thor
    class Runner < ::Thor::Runner

      #this works but I hate it
      register(HighFive::Thor::Tasks::Distribution, "dist", "dist [PLATFORM]", "Shortcut to distribution:dist")
      register(HighFive::Thor::Tasks::Deploy, "deploy", "deploy [PLATFORM]", "Shortcut to deploy:deploy")
      register(HighFive::Thor::Tasks::Initialization, "init", "init", "Shortcut to Initialization:init")

      # Note: because of the way task.run works, there has to be a local
      # definition. Also, we want tasks to work WITH our base namespace
      # if it is included, so that we can use our binary with the same
      # signature we would use thor
      def method_missing(meth, *args)
        meth = meth.to_s
        #meth.sub!(/^high_five:/, '')
        if (!meth.match(/:/))
          meth = "high_five:#{meth}"
        end
        super meth, *args
      end

      class_option :version, type: :boolean, desc: "Print version and ext", aliases: "-v"
      def initialize(*args)
        super
        #override version task
        if args[2][:current_task][:name] == "version"
          puts "HighFive #{HighFive::VERSION}" 
          Process.exit(0)
        end
      end

      private
      def thorfiles(*args)
        Dir[File.join(File.dirname(__FILE__), 'tasks/*.rb')]
      end

    end
  end
end