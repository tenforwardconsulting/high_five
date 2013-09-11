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
  end
end