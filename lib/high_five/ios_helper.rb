module HighFive
  module IosHelper
    def self.uuid_from_mobileprovision(path)
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

    def self.info_plist_path(platform_config)
      destination_dir = platform_config.destination
      root_dir = destination_dir
      while true
        break if (Dir[File.join(root_dir, "*.xcodeproj")].length > 0) 
        root_dir = File.expand_path("..", root_dir)
        raise "Couldn't find xcodeproj near #{destination_dir}" if root_dir == '/'
      end
      info =  Dir["#{root_dir}/**/*-Info.plist"].first
      raise "Couldn't find infoplist" if info.nil?
      return info
    end
  end
end