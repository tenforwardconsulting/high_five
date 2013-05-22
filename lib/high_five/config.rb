require 'json'
module HighFive
  class Config
    attr_accessor :root,         # Root of the project 
      :destination,  # generated folder for project('www')
      :page_title,   # <title>#{page_title}</title>
      :meta,          # config.meta << { http-equiv: "Content-Type" content: "text/html; charset=utf-8" }
      :static_assets,
      :static_javascripts,
      :static_stylesheets,
      :sass_files,
      :asset_paths,
      :platform_configs,
      :compass_dir,
      :js_settings, #serialized out to HighFive.Settings in index.html
      :is_environment, #boolean for if this config is an environment platform
      :dev_index #copy generated index.html to here on build for use in development


    def self.configure(&block) 
      @@instance = HighFive::Config.new
      yield @@instance

      if @@instance.root.nil?
        raise "HighFive::Config.root is required"
      end
    end

    def self.load
      begin
        require File.join(Dir.pwd, "config", "high_five.rb")
      rescue LoadError
        raise "high_five configuration not found, forgot to run 'hi5 init'?"
      end
      return @@instance 
    end

    def self.instance
      @@instance
    end

    def build_platform_config(platform)
      if @platform_configs[platform.to_s]
        new_config = HighFive::Config.new(@platform_configs[platform.to_s])
        new_config.root ||= self.root
        new_config.destination ||= self.destination
        new_config.meta ||= self.meta
        new_config.page_title ||= self.page_title
        new_config.static_assets += self.static_assets
        new_config.static_javascripts += self.static_javascripts
        new_config.static_stylesheets += self.static_stylesheets
        new_config.sass_files += self.sass_files
        new_config.asset_paths += self.asset_paths
        new_config.compass_dir ||= self.compass_dir
        new_config.dev_index ||= self.dev_index
        new_config.js_settings.merge! self.js_settings do |key, new_setting, old_setting| 
          new_setting || old_setting #don't clobber settings from the parent
        end
        new_config.platform_configs = @platform_configs.reject do |key, platform_config|
          key == platform
        end
        return new_config
      else
        return self
      end
    end

    def initialize(config=nil)
      if config
        @static_assets = config.static_assets.dup
        @static_javascripts = config.static_javascripts.dup
        @static_stylesheets = config.static_stylesheets.dup
        @sass_files = config.sass_files.dup
        @meta = config.meta.dup
        @asset_paths = config.asset_paths.dup
        @js_settings = config.js_settings.dup
        self.root = config.root
        self.destination = config.destination
        self.dev_index = config.dev_index
        self.page_title = config.page_title
        self.meta = config.meta
      else
        @static_assets = []
        @static_javascripts = []
        @static_stylesheets = []
        @sass_files = []
        @meta = {}
        @platform_configs = {}
        @asset_paths = []
        @js_settings = {}
      end
      @is_environment = false
    end 

    def assets(path)
      @static_assets << path.dup
    end

    def javascripts(path)
      @static_javascripts << path.dup
    end

    def sass(path) 
      @sass_files << path.dup
    end

    def compass(config_dir)
      @compass_dir = config_dir
    end

    def stylesheets(path)
      @static_stylesheets << path.dup
    end

    def platform(name, &block)
      @platform_configs[name.to_s] = HighFive::Config.new
      yield @platform_configs[name.to_s]
    end

    def environment(name, &block)
      platform(name, &block)
      @platform_configs[name.to_s].is_environment = true
    end

    def setting(hash)
      @js_settings.merge!(hash)
    end
    alias settings setting

    def high_five_javascript
      js = '<script type="text/javascript">'
      js += "if(typeof(window.HighFive)==='undefined'){window.HighFive={};}window.HighFive.Settings=#{JSON.dump(js_settings)};"
      js += '</script>'
      js
    end

    #easy setters

    def dev_index(*args)
      if args.length == 1
        @dev_index = args[0] 
      end
      @dev_index 
    end

    def destination(*args)
      @destination = args[0] if args.length == 1
      @destination
    end
  end
end