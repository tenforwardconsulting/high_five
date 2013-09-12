require 'high_five/android_helper'

module HighFive
  module Thor
    module Tasks
      class Android < ::HighFive::Thor::Task
        desc "android_debug", "build the debug apk via ant debug"
        def android_debug
          @destination_root = base_config.root
          puts "Debugy"
        end

        desc "build", "build the apk"
        def build
          run('ant -file build.xml "-Dkey.store=/Users/Shared/Jenkins/Home/jobs/modern resident/workspace/modern_resident-mobile/android/Keystore.ks" -Dkey.store.password=modernresident -Dkey.alias=android -Dkey.alias.password=modernresident clean release
            Buildfile: /Users/Shared/Jenkins/Home/jobs/modern resident/workspace/modern_resident-mobile/android/build.xml')
        end
      end
    end
  end
end