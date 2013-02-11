module HighFive
    class Config
        attr_accessor :root,         # Root of the project 
                      :destination,  # generated folder for project('www')
                      :page_title,   # <title>#{page_title}</title>
                      :meta,          # config.meta << { http-equiv: "Content-Type" content: "text/html; charset=utf-8" }
                      :static_assets

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

        def build_platform_config(platform)
          if @platform_configs[platform.to_s]
            new_config = HighFive::Config.new(@platform_configs[platform.to_s])
            new_config.root ||= self.root
            new_config.destination ||= self.destination
            new_config.meta ||= self.meta
            new_config.page_title ||= self.page_title
            new_config.static_assets += self.static_assets
            return new_config
          else
            return self
          end
        end

        def initialize(config=nil)
            if config
              @static_assets = config.static_assets.dup
              @meta = config.meta.dup
              self.root = config.root
              self.destination = config.destination
              self.page_title = config.page_title
              self.meta = config.meta
            else
              @static_assets = []
              @meta = {}
              @platform_configs = {}
            end
        end 

        def assets(path)
            @static_assets << path.dup
        end

        def platform(name, &block)
          @platform_configs[name.to_s] = HighFive::Config.new
          yield @platform_configs[name.to_s]
        end
    end
end