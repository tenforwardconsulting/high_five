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
      :asset_paths


    def self.configure(&block) 
      @@instance = HighFive::Config.new
      yield @@instance
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
        new_config.static_javascripts += self.static_javascripts
        new_config.static_stylesheets += self.static_stylesheets
        new_config.sass_files += self.sass_files
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
        self.root = config.root
        self.destination = config.destination
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
      end
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

    def compass(config_file)
      @compass_configs << config_file.dup
    end

    def stylesheets(path)
      @static_stylesheets << path.dup
    end

    def platform(name, &block)
      @platform_configs[name.to_s] = HighFive::Config.new
      yield @platform_configs[name.to_s]
    end
  end
end