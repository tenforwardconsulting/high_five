require 'high_five/ios_helper'
require 'plist' 

module HighFive
  module Thor
    module Tasks
      class IosTasks < ::HighFive::Thor::Task
        namespace :ios
        desc "set_version", "build the debug apk via ant debug"
        method_option :version, :aliases => "-v", :desc => "Set main version"
        method_option :build_number, :aliases => '-b', :desc => "set build number"
        def set_version
          info = ::HighFive::IosHelper.info_plist_path(base_config.build_platform_config(:ios))
          puts "Using #{info}"
          plist = Plist::parse_xml(info)

          if (options[:version])
            puts "Changing version from #{plist["CFBundleShortVersionString"]} => #{options[:version]}"
            plist["CFBundleShortVersionString"] = options[:version]
          end

          if (options[:build_number])
            puts "Changind build number from #{plist["CFBundleVersion"]} => #{options[:build_number]}"
            plist["CFBundleVersion"] = options[:build_number]
          end
          File.open(info, 'w') do |f|
            f.write(Plist::Emit.dump(plist))
          end
          puts "Wrote Info.plist succesfully"
        end
      end
    end
  end
end