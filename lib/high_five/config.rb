require 'multi_json'
module HighFive
  class Config
    attr_accessor :meta,          # config.meta << { http-equiv: "Content-Type" content: "text/html; charset=utf-8" }
                  :static_assets,
                  :static_javascripts,
                  :static_stylesheets,
                  :sass_files,
                  :asset_paths,
                  :platform_configs,
                  :js_settings, #serialized out to HighFive.Settings in index.html
                  :is_environment #boolean for if this config is an environment platform


    # shorthand for me to define lots and lots of config settings that need to be handled
    # as attr_accessible, settable via setting(blah) instead of settings=blah, and also
    # persisted to derived platform configs
    def self.config_setting(*settings)
      config_variables = []
      settings.each do |setting|
        attr_accessor setting
        var = "@#{setting}".to_sym
        config_variables << var
        define_method setting do |*args|
          instance_variable_set(var, args[0]) if args.length == 1
          instance_variable_get(var)
        end
      end
      @@config_variables = config_variables
    end

    config_setting :root,             # Root of the project
                   :destination,      # generated folder for project('www')
                   :page_title,       # <title>#{page_title}</title>
                   :compass_dir,      # directory that contaings compass' config.rb
                   :dev_index,        # copy generated index.html to here on build for use in development
                   :minify,           # defaults to true in production mode and false otherwise, overridable
                   :manifest,         # generate html5 manifest
                   :app_name,         # App Name
                   :app_id,           # App id (com.tenforwardconsulting.myapp)
                                      # config options below are used in the dist/build tasks
                   :android_manifest, # Path to the android manifest, relative to the project root
                   :ios_target        # ios target to be used by dist tasks

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
        @@config_variables.each do |svar|
          if (new_config.instance_variable_get(svar).nil?)
            new_config.instance_variable_set(svar, self.instance_variable_get(svar))
          end
        end
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
        self.minify = config.minify
        self.manifest = config.manifest
        @@config_variables.each do |svar|
          if (self.instance_variable_get(svar).nil?)
            self.instance_variable_set(svar, config.instance_variable_get(svar))
          end
        end
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

    def assets(path, options={})
      @static_assets << [path.dup, options.dup]
    end

    def javascripts(path)
      @static_javascripts << path.dup
    end

    def sass(path)
      @sass_files << path.dup
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
      platform_config = @platform_configs[name.to_s]
      platform_config.is_environment = true
      if (name.to_s == 'production')
        platform_config.minify = :uglifier if platform_config.minify.nil?
      end
    end

    def setting(hash)
      @js_settings.merge!(hash)
    end
    alias settings setting

    def high_five_javascript
      js = '<script type="text/javascript">'
      js += "if(typeof(window.HighFive)==='undefined'){window.HighFive={};}window.HighFive.Settings=#{MultiJson.dump(js_settings)};"
      js += '</script>'
      js
    end

    def windows!
      ExecJS::Runtimes::JScript.instance_variable_set(:"@encoding", "UTF-8")
      ExecJS::Runtimes::JScript.instance_variable_set(:"@command", "cscript //E:jscript //Nologo")
      ExecJS::Runtimes::JScript.instance_variable_set(:"@binary", "cscript //E:jscript //Nologo")
    end

  end
end
