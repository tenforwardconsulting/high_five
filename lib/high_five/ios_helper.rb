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
  end
end