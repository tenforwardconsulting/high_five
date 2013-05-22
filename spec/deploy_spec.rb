require 'spec_helper'

describe HighFive::DeployTask do 
  def create_dummy_app!
    @original_dir = Dir.pwd
    @project_root = Dir.mktmpdir("hi5")
    Dir.chdir @project_root
    FileUtils.cp_r(Dir[File.join(File.dirname(__FILE__), "dummy", "*")], @project_root)
  end

  def cli
    cli = HighFive::Cli.new
    cli.instance_variable_set("@base_config", HighFive::Config.instance)
    cli
  end

  def destroy_dummy_app!
    puts "Cleaning up deploy directory.  Contents: "
    system("find #{@project_root} -print | sed 's;[^/]*/;|___;g;s;___|; |;g'")
    Dir.chdir @original_dir
    FileUtils.rm_rf @project_root
  end
    
  context "Basic Deployment" do
    before :all do  
      create_dummy_app!
      HighFive::Config.configure do |config|
        config.root = @project_root
        config.destination = "www"
        config.platform :android do |android|
        
        end

        cli.deploy("android")
      end
    end

    after(:all) { destroy_dummy_app! }

    it "should deploy" do
      Dir.exists?(File.join(@project_root, "www")).should be_true
    end

    it "should copy all the javascript files" do
      File.join(@project_root, "www", "javascripts", "app").should exist
      File.join(@project_root, "www", "javascripts", "app", "component.js").should exist
    end

  end

  context "SASS Deployment" do 
    before :all do
      create_dummy_app!
      HighFive::Config.configure do |config|
        config.root = @project_root
        config.destination = "www"
        config.compass_dir = "."
        config.assets "stylesheets"
        config.platform :android do |android|
        
        end

        cli.deploy("android")
      end
    end

    after(:all) { destroy_dummy_app! }

    it "should invoke compass to compile stylesheets" do 
      expect(File.join(@project_root, "stylesheets", "screen.css")).to exist
    end

    it "should copy the css sheets to the deploy directory" do 
      pending "better compass integration"
      expect(File.join(@project_root, "www", "stylesheets", "screen.css")).to exist
    end
  end

  context "Development environment" do 
    before :all do
      create_dummy_app!
      HighFive::Config.configure do |config|
        config.root = @project_root
        config.destination = "www"
        config.compass_dir = "."
        config.assets "stylesheets"
        config.platform :web do |web|
          config.destination "www-web"
          config.dev_index "index-debug.html"
        end

        cli.deploy("web")
      end
    end

    it "should clone index.html to index-debug.html when directed" do 
      index = File.read(File.join(@project_root, "www-web", "index.html"))

      index_debug = File.read(File.join(@project_root, "index-debug.html"))
      index.should eq index_debug
    end
  end

end