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

    def info_plist_path
      root_dir = File.dirname(xcodeproj_path)
      info =  Dir["#{root_dir}/**/*-Info.plist"].first
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
  end
end