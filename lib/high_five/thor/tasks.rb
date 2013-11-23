module HighFive
  module Thor
    module Tasks
      def self.load
        Dir.glob(File.join(File.dirname(__FILE__), 'tasks', '**/*.rb')) do |file|
          ::Thor::Util.load_thorfile(file) if File.file?(file)
        end
      end
    end
  end
end
HighFive::Thor::Tasks.load