require 'high_five/ios_helper'
require 'high_five/android_helper'
module HighFive
  module Thor
    module Tasks
      class Distribution < ::HighFive::Thor::Task
        include ::Thor::Actions
        include IosHelper
        include AndroidHelper

        default_task :dist

        desc "dist [PLATFORM]", "Create a distribution package for a specific platform"
        method_option :output_file_name, :aliases => "-o", :desc => "Name of the final output file. Defaults to project_name.apk/ipa"
        method_option :sign_identity, :aliases => "-s", :desc => "Full name of the code sign identity for use by xcode"
        method_option :provisioning_profile, :aliases => "-p", :desc => "Path to the provisioning profile"
        method_option :target, :desc => "iOS target to build (can also be set in environment)"
        method_option :install, :aliases => "-i", type: :boolean, :desc => "Install on device after building"
        method_option :environment, :aliases => "-e", :desc => "Environemnt [production|development]", :default => "development"

        def dist(platform)
          @environment            = options[:environment]
          @output_file_name       = options[:output_file_name]
          @sign_identity          = options[:sign_identity]
          @provisioning_profile   = options[:provisioning_profile]
          @platform               = platform
          @config                 = base_config.build_platform_config(@platform).build_platform_config(@environment)
          @config_root            = File.join("config", "high_five")

          raise "Please set config.destination" if @config.destination.nil?
          self.destination_root = @config.destination

          if @platform == "android" || @platform == "amazon"
            manifest_path = @config.android_manifest || android_manifest_path
            android_path = File.dirname(manifest_path)

            dist_android(android_path)
            if options[:install]
              install_android android_path
            end
          elsif @platform == "ios"
            raise "Please pass in the code sign identity to build an ios app. -s [sign_identity]" if @sign_identity.nil?
            raise "Please pass in the path to the provisioning profile to build an ios app. -p [provisioning_profile]" if @provisioning_profile.nil?

            ios_path = File.dirname(xcodeproj_path())

            if !ios_path
              raise "Couldn't find the path of the xcodeproj."
            end

            ios_project_name = File.basename(Dir[ios_path + "/*.xcodeproj"].first, '.xcodeproj')
            ios_target = options[:target] || @config.ios_target || ios_project_name
            keychain = ios_project_name.gsub(/\s/, '').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase + '-ios.keychain'

            @output_file_name ||= ios_target

            uuid = HighFive::IosHelper.uuid_from_mobileprovision(@provisioning_profile)
            ENV['uuid'] = uuid
            FileUtils.cp(@provisioning_profile, "#{ENV['HOME']}/Library/MobileDevice/Provisioning Profiles/#{uuid}.mobileprovision")
            system(%Q(cd "#{ios_path}";
              /usr/bin/xcodebuild -target "#{ios_target}" -configuration Release build "CONFIGURATION_BUILD_DIR=#{ios_path}/build" "CODE_SIGN_IDENTITY=#{@sign_identity}" PROVISIONING_PROFILE=$uuid))
            system(%Q(/usr/bin/xcrun -sdk iphoneos PackageApplication -v "#{ios_path}/build/#{ios_target}.app" -o "#{ios_path}/build/#{@output_file_name}.ipa" --embed "#{@provisioning_profile}" --sign "#{@sign_identity}"))
          end
        end

        desc "dist_android [ANDROID_PATH]", "Create a distribution package for android"
        method_option :output_file_name, :aliases => "-o", :desc => "Name of the final output file. Defaults to project_name.apk/ipa"
        def dist_android(android_path)
          @output_file_name       = options[:output_file_name]
          system("android update project --path #{android_path} --subprojects")
          system("ant -file '#{android_path}/build.xml' release")

          android_name = HighFive::AndroidHelper.project_name_from_build_xml("#{android_path}/build.xml")
          if @output_file_name
            FileUtils.cp("#{android_path}/bin/#{android_name}-release.apk", "#{android_path}/bin/#{@output_file_name}.apk")
          end
        end

        desc "install_android [ANDROID_PATH]", "Install the distribution package on the connected android device or emulator"
        def install_android(android_path)
          system("ant -file '#{android_path}/build.xml' installr")
        end
      end
    end
  end
end
