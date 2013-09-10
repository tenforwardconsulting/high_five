module HighFive
  module DistTask

    def self.included(mod)
      mod.class_eval do

        desc "dist", "Create a distribution package for a specific platform"
        method_option :environment, :aliases => "-e", :desc => "Environemnt [production|development]", :default => "development"
        def dist(target)
          @environment  = options[:environment]
          @platform     = target
          @config       = base_config.build_platform_config(@platform).build_platform_config(@environment)
          @config_root  = File.join("config", "high_five")

          raise "Please set config.destination" if @config.destination.nil?
          self.destination_root = @config.destination

          if @platform == "android" || @platform == "amazon"
            path = self.destination_root
            while path != base_config.root
              if File.exists? File.join(path, 'AndroidManifest.xml')
                android_path = path
                break
              else
                path = File.expand_path('..', path)
              end
            end

            if !android_path
              raise "Couldn't find the path of the android manifest.  Maybe we should allow you to pass it in."
            end

            system("ant -file '#{android_path}/build.xml' release")
            #rename the file maybe?

          elsif @platform == "ios"
            #i think the mobileprovision is going to be moved
            system('uuid=`grep UUID -A1 -a cloud_five.mobileprovision | grep -o "[-A-Z0-9]\{36\}"`')
            system("cp cloud_five.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision")

            path = self.destination_root
            while path != base_config.root
              if !Dir[path + "/*.xcodeproj"].empty?
                ios_path = path
                break
              else
                path = File.expand_path('..', path)
              end
            end

            if !ios_path
              raise "Couldn't find the path of the xcodeproj.  Maybe we should allow you to pass it in."
            end

            system("")
          end
        end
      end
    end
  end
end