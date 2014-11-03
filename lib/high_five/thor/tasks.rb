module HighFive
  module Thor
    module Tasks
      def self.load
        Dir.glob(File.join(File.dirname(__FILE__), 'tasks', '**/*.rb')) do |file|
          if File.file?(file)
            ::Thor::Util.load_thorfile(file)
            require file
          end
        end
      end
    end
  end
end

HighFive::Thor::Tasks.load