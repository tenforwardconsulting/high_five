require 'high_five/ios_helper'
require 'high_five/android_helper'
module HighFive
  module Thor
    module Tasks
      class Dist < ::HighFive::Thor::Task
        include ::Thor::Actions
        include ::HighFive::IosHelper
        include ::HighFive::AndroidHelper

        default_task :dist

        desc "dist [PLATFORM]", "Create a distribution package for a specific platform"
        method_option :output_file_name, :aliases => "-o", :desc => "Name of the final output file. Defaults to project_name.apk/ipa"
        method_option :sign_identity, :aliases => "-s", :desc => "Full name of the code sign identity for use by xcode"
        method_option :provisioning_profile, :aliases => "-p", :desc => "Path to the provisioning profile"
        method_option :target, :desc => "iOS target to build (can also be set in environment)"
        method_option :install, :aliases => "-i", type: :boolean, :desc => "Install on device after building"
        method_option :environment, :aliases => "-e", :desc => "Environemnt [production|development]", :default => "development"
        method_option :"ant-flags", :desc => "Additional flags to pass directly to ant (android only)"
        method_option :platform_path, :desc => "Path to ios or android directory"
        method_option :ant, type: :boolean, :desc => "Force using ant to build"
        def dist(platform)
          @environment            = options[:environment]
          @output_file_name       = options[:output_file_name]
          @sign_identity          = options[:sign_identity]
          @provisioning_profile   = options[:provisioning_profile]
          @platform_path          = options[:platform_path]
          @platform               = platform

          if @platform == "android" || @platform == "amazon"
            if @platform_path
              android_path = @platform_path
            else
              manifest_path = config.android_manifest || android_manifest_path
              android_path = File.dirname(manifest_path)
            end

            dist_android(android_path)
            if options[:install]
              install_android android_path
            end
          elsif @platform == "ios"
            raise "Please pass in the code sign identity to build an ios app. -s [sign_identity]" if @sign_identity.nil?
            raise "Please pass in the path to the provisioning profile to build an ios app. -p [provisioning_profile]" if @provisioning_profile.nil?

            ios_project_name = File.basename(Dir[ios_path + "/*.xcodeproj"].first, '.xcodeproj')
            ios_target = options[:target] || config.ios_target || ios_project_name
            keychain = ios_project_name.gsub(/\s/, '').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase + '-ios.keychain'

            @output_file_name ||= ios_target

            uuid = HighFive::IosHelper.uuid_from_mobileprovision(@provisioning_profile)
            ENV['uuid'] = uuid
            FileUtils.cp(@provisioning_profile, "#{ENV['HOME']}/Library/MobileDevice/Provisioning Profiles/#{uuid}.mobileprovision")
            system_or_die("rm -rf #{ios_path}/build/*")
            system_or_die(%Q(cd "#{ios_path}";
              /usr/bin/xcodebuild -target "#{ios_target}" -configuration Release clean build "CONFIGURATION_BUILD_DIR=#{ios_path}/build" "CODE_SIGN_IDENTITY=#{@sign_identity}" PROVISIONING_PROFILE=$uuid))
            system_or_die(%Q(/usr/bin/xcrun -sdk iphoneos PackageApplication -v "#{ios_path}/build/#{ios_target}.app" -o "#{ios_path}/build/#{@output_file_name}.ipa" --embed "#{@provisioning_profile}"))
          end
        end

        desc "dist_android [ANDROID_PATH]", "Create a distribution package for android"
        method_option :output_file_name, :aliases => "-o", :desc => "Name of the final output file. Defaults to project_name.apk/ipa"
        method_option :"ant-flags", :desc => "Additional flags to pass directly to ant"
        def dist_android(android_path)
          @output_file_name       = options[:output_file_name]
          ant_flags = options[:"ant-flags"] || ""
          system_or_die("android update project --path #{android_path} --subprojects")
          gradle_file = File.join(android_path, "build.gradle")
          gradle = File.exists?(gradle_file) && !options[:ant]
          if gradle
            system_or_die("gradle -b #{gradle_file} clean assembleRelease")
          else
            system_or_die("ant -file '#{android_path}/build.xml' clean release #{ant_flags}")
          end

          android_name = HighFive::AndroidHelper.project_name_from_build_xml("#{android_path}/build.xml")

          if @output_file_name
            if gradle
              say "copying final build #{android_path}/build/outputs/apk/android-release.apk -> #{android_path}/build/outputs/apk/#{@output_file_name}.apk"
              FileUtils.cp("#{android_path}/build/outputs/apk/android-release.apk", "#{android_path}/build/outputs/apk/#{@output_file_name}.apk")
            else
              say "copying final build #{android_path}/bin/#{android_name}-release.apk -> #{android_path}/bin/#{@output_file_name}.apk"
              FileUtils.cp("#{android_path}/bin/#{android_name}-release.apk", "#{android_path}/bin/#{@output_file_name}.apk")
            end
          end
        end

        desc "install_android [ANDROID_PATH]", "Install the distribution package on the connected android device or emulator"
        def install_android(android_path)
          system_or_die("ant -file '#{android_path}/build.xml' installr")
        end

        private

        def system_or_die(cmd)
          system(cmd)
          if $?.exitstatus != 0
            exit $?.exitstatus
          end
        end

        def config
          base_config.build_platform_config(@platform).build_platform_config(@environment)
        end
      end
    end
  end
end
