require 'high_five/config'

module HighFive
  module Thor
    class Task < ::Thor
      def self.banner(task, namespace = false, subcommand = true)
        if self.namespace == "high_five"
          ns = ""
        else
          ns = "#{self.namespace}:"
        end
        "hi5 #{ns}" + task.formatted_usage(self, namespace, subcommand)
      end

      no_tasks {
        def invoke(name=nil, *args)
          name.sub!(/^high_five:/, '') if name && $high_five_runner
          super
        end
        
        class << self
          def inherited(base) #:nodoc:
            base.send :extend,  ClassMethods
          end
        end

        def base_config
          begin 
            @base_config ||= HighFive::Config.load
          rescue StandardError => e
            raise e
            say e.message, :red
            exit
          end
        end
      }

      def initialize(*args)
        super
       
      end
    
      module ClassMethods
        def namespace(name=nil)
          case name
          when nil
            constant = self.to_s.gsub(/^Thor::Sandbox::/, "")
            strip = $high_five_runner ? /^HighFive::Thor::Tasks::/ : /(?<=HighFive::)Thor::Tasks::/
            constant = constant.gsub(strip, "")
            constant =  ::Thor::Util.snake_case(constant).squeeze(":")          
            @namespace ||= constant
          else
            super
          end
        end
      end
    end  
  end
end