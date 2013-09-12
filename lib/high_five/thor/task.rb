require 'high_five/config'

module HighFive
  module Thor
    class Task < ::Thor

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
            say e.message, :red
            exit
          end
        end
      }
    
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