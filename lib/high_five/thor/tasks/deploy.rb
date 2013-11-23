require 'sprockets'
require 'sass'
require 'uglifier'
require "yui/compressor"

module HighFive
  module Thor
    module Tasks
      class Deploy < ::HighFive::Thor::Task
        default_task :deploy
        include ::Thor::Actions

        desc "deploy", "Deploy the app for a specific platform in a specific environment"
        method_option :environment, :aliases => "-e", :desc => "Environemnt [production|development]", :default => "development"
        method_option :compress, :aliases => '-c', :desc => "Compress javascript [true]", :default => false
        method_option :weinre_url, :aliases => '-w', :desc => "Enter your Weinre server-url including port", :default => false
        method_option :"copy-files", :aliases => '-f', :desc => "Copy files to eclipse/xcode directory", :default => false
        def deploy(target)
          @environment  = options[:environment]
          @platform     = target
          @weinre_url   = options[:weinre_url]
          @copy_files   = options[:"copy-files"]
          @meta         = {}
          @config       = base_config.build_platform_config(@platform).build_platform_config(@environment)
          @config_root  = File.join("config", "high_five")
          
          self.source_paths << File.join(base_config.root, @config_root)
          self.source_paths << File.join(base_config.root)
          self.source_paths << File.join(File.dirname(__FILE__), 'generators')
          @config.asset_paths.each do |asset_path|
            self.source_paths << asset_path
          end


          raise "Please set config.destination" if @config.destination.nil?
          self.destination_root = @config.destination
          FileUtils.rm_rf(self.destination_root)
          FileUtils.mkdir_p(self.destination_root)

          #todo add to config
          say "Deploying app: <#{@platform}> <#{options[:environment]}>"
          say "\t#{self.destination_root}"
          say " -Weinre url: #{@weinre_url}" if @weinre_url
          
          if @config.compass_dir
            compass_dir = File.join(base_config.root, @config.compass_dir)
            say "Precompiling compass styles from #{compass_dir}}"
            pwd = Dir.pwd
            Dir.chdir compass_dir
            success = false
            if @environment == "production"
              success = system("compass compile --force --no-debug-info -e production")
            else
              success = system("compass compile --force --no-debug-info")
            end
            unless success
              raise "Error compiling CSS, aborting build"
            end
            Dir.chdir pwd
          end

          # Bundle is based on the provided build platformx
          platform_file = File.join(@config_root, "app-#{@platform}.js")
          bundle = builder.find_asset platform_file
          if bundle.nil?
            p source_paths
            error "#{@platform} is not a valid target.  Please create #{platform_file}" and Process.exit
          end
          

          if (@environment == "production")
            appjs = File.join(self.destination_root, "app.js")
            @javascripts = ["app.js"]
            
            output_js = nil
            if @config.minify  == :uglifier
              say "      uglify  #{appjs}", :green
              output_js = Uglifier.compile(bundle.to_s)
            elsif @config.minify == :yui
              say "      minify  #{appjs}", :green
              output_js = YUI::JavaScriptCompressor.new.compress(bundle.to_s)
            else
              say "      create  #{appjs}", :green
              output_js = bundle.to_s
            end
            File.open(appjs, "w") do |file| 
              file.write output_js
            end
            output_js = nil
          else
            # Add each of the javascript files to the generated folder
            @javascripts = []
            bundle.dependencies.each do |asset|
              next if asset.logical_path =~ /^config\/high_five/ #don't copy manifest files
              copy_file asset.logical_path
              @javascripts << asset.logical_path
            end
          end

          # Adds each of the static javascripts
          @config.static_javascripts.each do |javascript|
            if File.directory? javascript
              directory javascript
              @javascripts.unshift(*Dir[File.join(javascript,'**','*.js')])
            else
              copy_file javascript unless javascript =~ /^https?:\/\// 
              @javascripts.unshift javascript
            end
          end

          @stylesheets = []
          @config.sass_files.each do |sass_file|
            asset_name = File.basename(sass_file, File.extname(sass_file)) 
            css_file = File.join(self.destination_root, "stylesheets", "#{asset_name}.css")
            say "Compiling #{sass_file} -> #{css_file}"
            Sass.compile_file sass_file, css_file
            @stylesheets.push css_file
            copy_file css_file
          end

          @config.static_stylesheets.each do |stylesheet|
            if File.directory? stylesheet
              directory stylesheet
              @stylesheets.unshift(*Dir[File.join(stylesheet,'**','*.css')])
            else
              copy_file stylesheet
              @stylesheets.unshift stylesheet
            end
          end

          # Adds each of the static assets to the generated folder (sylesheets etc)
          @config.static_assets.each do |path|
            asset = find_in_source_paths(path)
            if File.directory? asset
              directory asset, path
            else
              copy_file asset, path
            end
          end

          if (@config.manifest && @environment == 'production')
            @manifest_attr = %Q(manifest="manifest.appcache") #for <html manifest=>
            say "     create manifest", :green
            @manifest_cache = @config.static_assets.collect do |path|
              if (File.directory?(path))
                Dir.glob(path + "/**/*").reject {|x| File.directory?(x) }
              else
                path
              end
            end.flatten

            @manifest_cache += @javascripts
            @manifest_cache += @stylesheets

            template "manifest.erb", File.join(self.destination_root, "manifest.appcache")
          end

          @high_five_javascript = @config.high_five_javascript
          # Build index.html
          say "Generating index.html"
          template File.join(@config_root, "index.html.erb"), File.join(self.destination_root, "index.html")
          if (@environment == 'development' && !@config.dev_index.nil?)
            say "Cloning to #{@config.dev_index}"
            FileUtils.cp(File.join(self.destination_root, "index.html"), File.join(@config.root, @config.dev_index))
          end
        end
      
        private 

        def builder
          @builder ||= get_builder
        end

        def get_builder
          builder = Sprockets::Environment.new(File.join(base_config.root))
          builder.append_path base_config.root
          builder.append_path File.join(base_config.root, @config_root)
          @config.asset_paths.each do |path|
            full_path = File.join(base_config.root, path)
            say "adding asset search path #{full_path}"
            builder.append_path full_path
          end
          builder
        end

        #TODO: this probably doesn't work on windows 
        def compress_javascript(file_name)
          say " -Compressing #{file_name} with yuicompressor", :yellow

          compressor = 'yuicompressor'
          if `which yuicompressor`.empty?
            compressor = 'yui-compressor'
            if `which yui-compressor`.empty?
              say "ERROR: you don't have a yuicompressor installed", :red
              say " Are you sure yuicompressor is installed on your system?  Mac users, run this in console:", :red
              say " $ brew install yuicompressor", :red
              say " Ubuntu users: $sudo apt-get -y install yui-compressor", :red
            end
          end
          cmd = "#{compressor} #{file_name} -o #{file_name}"
          system(cmd)
          unless $?.exitstatus == 0
            say " ERROR: #{cmd}", :red
          end
        end
      end
    end
  end
end
