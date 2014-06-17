module HighFive
  module IosHelper
    def IosHelper.uuid_from_mobileprovision(path)
      uuid_found = false
      File.open(path, 'r', :encoding => 'iso-8859-1').each do |line|
        if uuid_found
          line =~ /<string>(.*)<\/string>/
          return $1
        end
        uuid_found = true if line =~ /UUID/
      end
      nil
    end


    def ios_path
      if options[:platform_path]
        ios_path = options[:platform_path]
      else
        ios_path = File.dirname xcodeproj_path
      end

      if !ios_path
        raise "Couldn't find the path of the xcodeproj."
      end

      ios_path
    end

    def info_plist_path(target=nil)
      root_dir = ios_path
      target = "*" if target.nil?
      info =  Dir["#{root_dir}/**/#{target}-Info.plist"].first
      raise "Couldn't find infoplist" if info.nil?
      return info
    end

    def xcodeproj_path
      platform_config = base_config.build_platform_config(:ios)
      destination_dir = platform_config.destination
      root_dir = destination_dir
      while true
        glob = Dir[File.join(root_dir, "*.xcodeproj")]
        return glob.first if (glob.length > 0)
        root_dir = File.expand_path("..", root_dir)
        raise "Couldn't find xcodeproj near #{destination_dir}" if root_dir == '/'
      end
    end

    def ios_icon_sizes
      {
        old_iphone: 57,
        old_iphone_retina: 114,
        iphone_retina: 120,
        old_ipad: 72,
        old_ipad_retina: 177,
        ipad: 76,
        ipad_retina: 152,
        old_spotlight: 29,
        old_spotlight_retina: 58,
        spotlight: 40,
        spotlight_retina: 80,
        spotlight_ipad: 50,
        spotlight_ipad_retina: 100
      }
    end
  end
end