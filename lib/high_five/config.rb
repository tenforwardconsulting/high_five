module HighFive
    class Config
        attr_accessor :root,         # Root of the project 
                      :destination,  # generated folder for project('www')
                      :page_title,   # <title>#{page_title}</title>
                      :meta          # config.meta << { http-equiv: "Content-Type" content: "text/html; charset=utf-8" }
        attr_reader :static_assets

        def self.configure(&block) 
            @@instance = HighFive::Config.new
            yield @@instance

            #validate
        end

        def self.load
            begin
                require File.join(HighFive::ROOT, "config", "high_five.rb")
            rescue LoadError
                raise "high_five configuration not found, forgot to run 'hi5 init'?"
            end
            return @@instance 
        end

        def initialize
            @static_assets = []
            @meta = {}
        end 

        def assets(path)
            @static_assets << path.dup
        end
    end
end