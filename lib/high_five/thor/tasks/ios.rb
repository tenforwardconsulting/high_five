require 'high_five/ios_helper'
require 'plist'

module HighFive
  module Thor
    module Tasks
      class Ios < ::HighFive::Thor::Task
        include ::Thor::Actions
        include ::HighFive::IosHelper
        include ::HighFive::ImageHelper

        desc "set_version", "build the debug apk via ant debug"
        method_option :version, :aliases => "-v", :desc => "Set main version"
        method_option :build_number, :aliases => '-b', :desc => "set build number"
        method_option :environment, :aliases => '-e', :desc => "environment"
        method_option :target, :aliases => '-t', :desc => "Use a specific target (i.e. <Target>.plist"
        method_option :platform_path, :desc => "Path to ios or android directory"
        def set_version
          if options[:version]
            set_plist_property "CFBundleShortVersionString", options[:version]
          end

          if options[:build_number]
            set_plist_property "CFBundleVersion", options[:build_number]
          end

          write_plist
        end

        desc "set_property", "Set an info.plist property"
        method_option :key, :aliases => "-k", :desc => "Key to change"
        method_option :value, :aliases => "-v", :desc => "New value for the specified key"
        method_option :environment, :aliases => '-e', :desc => "environment"
        method_option :target, :aliases => '-t', :desc => "Use a specific target (i.e. <Target>.plist"
        method_option :platform_path, :desc => "Path to ios or android directory"
        def set_property
          unless options[:key] && options[:value]
            raise "Need to set key and value options"
          end
          set_plist_property options[:key], options[:value]
          write_plist
        end

        desc "set_icon", "Generate app icons from base png image"
        method_option :target, :aliases => '-t', :desc => "Use a specific target (i.e. <Target>.plist)"
        method_option :platform_path, :desc => "Path to ios or android directory"
        def set_icon(path)
          begin
            icon_files = plist['CFBundleIcons']["CFBundlePrimaryIcon"]["CFBundleIconFiles"]
            icon_files += [ plist['CFBundleIconFile'] ]
            icon_files += plist['CFBundleIcons~ipad']["CFBundlePrimaryIcon"]["CFBundleIconFiles"]
          rescue
            icon_files = []
          end
          if icon_files.empty?
            icon_files = Dir.glob("#{ios_path}/**/AppIcon.appiconset/*.png")
          end
          icon_files.each do |icon_entry|
            icon_file_name = icon_entry
            unless icon_entry.end_with? ".png"
              icon_file_name += ".png"
            end

            # look in a directory named after the target first, if it's present
            # This helps with multi-target apps
            old_icon_path = Dir[File.join(ios_path, "#{target}/**/#{icon_file_name}")].first
            old_icon_path = Dir[File.join(ios_path, "**/#{icon_file_name}")].first if old_icon_path.nil?
            old_icon_path = Dir[File.join(icon_entry)].first if old_icon_path.nil?

            if old_icon_path.nil?
              puts "Skipping #{icon_entry} because the file is missing.  This will cause problems with app store submission"
              next
            end
            print "Replacing #{old_icon_path}..."
            old_image = ChunkyPNG::Image.from_file(old_icon_path)
            puts "#{old_image.width}x#{old_image.height}"
            replace_image(old_icon_path, path)
          end
        end

        desc "set_splash_screen", "Replace splash screens from base png image"
        method_option :color, desc: "Background color"
        def set_splash_screen(path)
          image = ChunkyPNG::Image.from_file(path)

          splashes_to_make = [
            'iphone_portrait_8_retina_hd_5_5',
            'iphone_portrait_8_retina_hd_4_7',
            'iphone_landscape_8_retina_hd_5_5',
            'iphone_portrait_1x',
            'iphone_portrait_2x',
            'iphone_portrait_retina_4',
            'ios-7-iphone_portrait_2x',
            'ios-7-iphone_portrait_retina_4',
            'ipad_portrait_1x',
            'ipad_portrait_2x',
            'ipad_landscape_1x',
            'ipad_landscape_2x',
            'ipad_portrait_without_status_bar_5_6_1x',
            'ipad_portrait_without_status_bar_5_6_2x',
            'ipad_landscape_without_status_bar_5_6_1x',
            'ipad_landscape_without_status_bar_5_6_2x'
          ]

          splashes_to_make.each do |type|
            generate_ios_splash_screen_image(type, ios_path, path, nil, true)
          end

          puts "Make sure you assign them in xcode if this is the first time you generated these"
        end

        desc "generate_splash_screen", "Generate and replace splash screens from logo and background color"
        method_option :color, desc: "Background color"
        def generate_splash_screen(path)
          image = ChunkyPNG::Image.from_file(path)

          splashes_to_make = [
            'iphone_portrait_8_retina_hd_5_5',
            'iphone_portrait_8_retina_hd_4_7',
            'iphone_landscape_8_retina_hd_5_5',
            'iphone_portrait_1x',
            'iphone_portrait_2x',
            'iphone_portrait_retina_4',
            'ios-7-iphone_portrait_2x',
            'ios-7-iphone_portrait_retina_4',
            'ipad_portrait_1x',
            'ipad_portrait_2x',
            'ipad_landscape_1x',
            'ipad_landscape_2x',
            'ipad_portrait_without_status_bar_5_6_1x',
            'ipad_portrait_without_status_bar_5_6_2x',
            'ipad_landscape_without_status_bar_5_6_1x',
            'ipad_landscape_without_status_bar_5_6_2x'
          ]

          splashes_to_make.each do |type|
            generate_ios_splash_screen_image(type, ios_path, path, options[:color] || "#ffffff")
          end

          puts "Make sure you assign them in xcode if this is the first time you generated these"
        end

        private

        def set_plist_property(key, value)
          puts "Changing #{key} from #{plist[key]} => #{value}"
          plist[key] = value
        end

        def write_plist
          File.open(plist_path, 'w') do |f|
            f.write(Plist::Emit.dump(plist))
          end
          puts "Wrote #{plist_path} succesfully"
        end

        def target
          options[:target] || base_config.build_platform_config(:ios).build_platform_config(options[:environment]).ios_target
        end

        def plist_path
          info_plist_path(target)
        end

        def plist
          @plist ||= Plist::parse_xml(plist_path)
        end
      end
    end
  end
end
