require 'chunky_png'
require 'high_five/android_helper'
require 'nokogiri'

module HighFive
  module Thor
    module Tasks
      class AndroidTasks < ::HighFive::Thor::Task
        include ::Thor::Actions
        include HighFive::AndroidHelper
        include ::HighFive::ImageHelper
        namespace :android

        desc "debug", "build the debug apk via ant debug"
        def debug(target)
          @destination_root = base_config.root
          puts "Debugy #{target}"
        end

        desc "build", "build the apk"
        def build
          run('ant -file build.xml "-Dkey.store=/Users/Shared/Jenkins/Home/jobs/modern resident/workspace/modern_resident-mobile/android/Keystore.ks" -Dkey.store.password=modernresident -Dkey.alias=android -Dkey.alias.password=modernresident clean release
            Buildfile: /Users/Shared/Jenkins/Home/jobs/modern resident/workspace/modern_resident-mobile/android/build.xml')
        end

        desc "set_version", "Change the version and build number"
        method_option :version, :aliases => "-v", :desc => "Set main version"
        method_option :build_number, :aliases => '-b', :desc => "set build number"
        method_option :environment, :aliases => '-e', :desc => "Set environment"
        method_option :platform_path, desc: "Path to the ios or android directory"
        def set_version
          # read and parse the old file
          file = File.read(android_manifest_path)
          xml = Nokogiri::XML(file)

          # replace \n and any additional whitespace with a space
          xml.xpath("//manifest").each do |node|
            if (options[:version])
              old = node["android:versionName"]
              node["android:versionName"] = options[:version]
              puts "Setting version #{old} => #{options[:version]}"
            end
            if (options[:build_number])
              old = node["android:versionCode"]
              node["android:versionCode"] = options[:build_number]
              puts "Setting versionCode #{old} => #{options[:build_number]}"
            end
          end

          # save the output into a new file
          File.open(android_manifest_path, "w") do |f|
            f.write xml.to_xml
          end
        end

        desc "set_icon", "Generate app icons from base png image"
        method_option :platform_path, desc: "Path to the ios or android directory"
        method_option :environment, :aliases => '-e', :desc => "Set environment"
        def set_icon(path)
          image = ChunkyPNG::Image.from_file(path)

          manifest = File.read(android_manifest_path)
          puts "Using android manifest: #{android_manifest_path}"
          icon_name = manifest.match(/android:icon="@drawable\/(.*?)"/)[1] + '.png'

          drawable_dir = File.join File.dirname(android_manifest_path), 'res'
          valid_directories(drawable_dir).each do |dir|
            res = parse_resolution(dir)
            size = res_map[res]
            icon_path = File.join(dir, icon_name)
            replace_image icon_path, path
            puts "Writing #{size}x#{size} -> #{icon_path}"
          end
        end

        private
        def config
          base_config.build_platform_config(:android).build_platform_config(options[:environment])
        end
      end
    end
  end
end
