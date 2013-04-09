module HighFive
  module AndroidTasks
    def self.included(mod)
      mod.class_eval do 

        namespace "android"
        desc "android_debug", "build the debug apk via ant debug"
        def android_debug
          self.destination_root = HighFive::ROOT
          puts "Debugy"
        end


      end #end class_eval
    end
  end
end
