require 'sprockets'
require 'pry'
module HighFive
  module DeployTask 

    def deploy_task
      config = HighFive::Config.load
      @environment  = options[:environment]
      @platform     = options[:platform]
      @compress     = options[:compress]
      @weinre_url   = options[:weinre_url]
      @copy_files   = options[:"copy-files"]
      @meta         = {}

      self.destination_root = config.destination
      FileUtils.rm_rf(self.destination_root)

      #todo add to config
      say "Deploying app: <#{options[:platform]}> <#{options[:environment]}>"
      say " -Weinre url: #{@weinre_url}" if @weinre_url

      # Compile CSS
      pwd = Dir.pwd
      
      #todo customize this
      # Dir.chdir File.join("assets", "sass")
      # success = false
      # if @environment == "production"
      #   success = system("compass compile --force --no-debug-info -e production #{options[:platform]}.scss")
      # else
      #   success = system("compass compile --force --no-debug-info #{options[:platform]}.scss")
      # end
      # unless success
      #   raise "Error compiling CSS, aborting build"
      # end
      # Dir.chdir pwd

      # Build javascript
      # inside "assets" do |assets|
      #   directory "images"
      #   directory "stylesheets"
      #   inside "javascripts" do |dir|
      #     if @compress == true
      #       build_javascript :from => "app-#{@platform}", :to => 'app-all.js'
      #       compress_javascript "app-all.js"
      #     else      
      #       bundle = builder.find_asset "app-#{@platform}"
      #       @js_files = bundle.dependencies.map {|asset| File.join("assets",  asset.logical_path) }
      #       copy_file "app.js"
      #       directory "app"
      #       directory "config"
      #       directory "lib"
      #       directory "platform/phonegap" unless @platform == 'web'
      #       directory "platform/#{@platform}"
      #     end

      #   end

      bundle = builder.find_asset "app-#{@platform}"
      @javascripts = bundle.dependencies.map do |asset| 
        copy_file asset.logical_path
        asset.logical_path
      end
      @stylesheets = []
            
      #   inside "stylesheets" do |dir|
      #     # Copy generated css
      #     copy_file "#{@platform}.css", "theme.css"
      #   end
      # end
        
      # Build index.html

      template "high_five.html.erb", File.join(self.destination_root, "index.html")

      # if (@copy_files) 
      #   dest = nil
      #   # copy to platform build directories
      #   if (@platform == 'android')
      #     dest = File.join(HighFive::ROOT, "..", "account_assistant-android/assets/www")
      #   elsif (@platform == 'ios') 
      #     dest = File.join(HighFive::ROOT, "..", "account_assistant-ios/www")
      #   end

      #   if (!dest.nil? && File.exists?(dest))
      #     say "Copying to #{@platform} native project: #{dest}"
      #     FileUtils.rm_rf(dest)
      #     directory self.destination_root, dest
      #   end
      # end
    end
  
    private 

    def builder
      @builder ||= get_builder
    end

    def get_builder
      builder = Sprockets::Environment.new(File.join(HighFive::ROOT))
      builder.append_path '.'
      #builder.append_path 'assets'


      builder
    end

    def build_javascript(options)

      build = builder.find_asset options[:from]
      say "      create  www/assets/javascripts/#{options[:to]}", :green
      build.write_to(options[:to])
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
