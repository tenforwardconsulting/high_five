module HighFive
  module AndroidHelper
    def self.project_name_from_build_xml(path)
      File.open(path, 'r', :encoding => 'iso-8859-1').each do |line|
        if line =~ /<project name="(.*)" /
          return $1
        end
      end
      nil
    end

    def res_map
      {
        ldpi: 36,
        mdpi: 48,
        hdpi: 72,
        xhdpi: 96,
        drawable: 512
      }
    end

    def android_manifest_path
      platform_config = base_config.build_platform_config(:android)
      destination_dir = platform_config.destination
      root_dir = destination_dir
      while true
        glob = Dir[File.join(root_dir, "AndroidManifest.xml")]
        return glob.first if (glob.length > 0)
        root_dir = File.expand_path("..", root_dir)
        raise "Couldn't find android manifest near #{destination_dir}" if root_dir == '/'
      end
    end
  end
end
