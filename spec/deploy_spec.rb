require 'spec_helper'

describe HighFive::Thor::Tasks::Deploy do
  include HighFive::TestHelper

  context "Basic Deployment" do
    before :all do
      create_dummy_app!
      HighFive::Config.configure do |config|
        config.root = @project_root
        config.destination = "www"
        config.platform :android do |android|

        end
      end
      cli(HighFive::Thor::Tasks::Deploy).deploy("android")
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
      end
      cli(HighFive::Thor::Tasks::Deploy).deploy("android")
    end

    after(:all) { destroy_dummy_app! }

    it "should invoke compass to compile stylesheets" do
      expect(File.join(@project_root, "stylesheets", "sass.css")).to exist
      expect(File.join(@project_root, "www", "stylesheets", "sass.css")).to exist
    end

    it "should copy the css sheets to the deploy directory" do
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
      end
      cli(HighFive::Thor::Tasks::Deploy).deploy("web")
    end

    after(:all) { destroy_dummy_app! }

    it "should clone index.html to index-debug.html when directed" do
      index = File.read(File.join(@project_root, "www-web", "index.html"))
      index_debug = File.read(File.join(@project_root, "index-debug.html"))
      index.should eq index_debug
    end
  end

  context "Production environment" do
    before :all do
      create_dummy_app!
      HighFive::Config.configure do |config|
        config.root = @project_root
        config.destination = "www"
        config.compass_dir = "."
        config.assets "stylesheets"
        config.platform :web do |web|
           config.dev_index "index-debug.html"
           config.manifest = true
        end
        config.environment :production do |prod|
          prod.minify = :yui
        end

      end
      cli(HighFive::Thor::Tasks::Deploy, environment: 'production').deploy("web")
    end

    after(:all) { destroy_dummy_app! }

    it "should produce just one javascript file" do
      expect(File.join(@project_root, "www", "app.js")).to exist
    end
    it "should not clone index.html to index-debug.html" do
      File.exist?(File.join(@project_root, "index-debug.html")).should be_false
    end
    it "should generate an html manifest" do
      expect(File.join(@project_root, "www", "manifest.appcache")).to exist
    end
  end

  context "Custom Asset paths" do
    before :all do
      create_dummy_app!
      HighFive::Config.configure do |config|
        config.root = @project_root
        config.destination = "www"
        config.asset_paths = ["public/custom_path"]
        config.platform :custom_asset_paths do |custom_asset_paths|
        end

      end
      cli(HighFive::Thor::Tasks::Deploy).deploy("custom_asset_paths")
    end

    after(:all) { destroy_dummy_app! }

    it "should process files from custom asset paths" do
      expect(File.join(@project_root, "www", "public/custom_path/custom_app.js")).to exist
    end

    it "should process a directory from the custom asset paths" do
      expect(File.join(@project_root, "www", "public/custom_path/custom_app/controllers/custom_controller.js")).to exist
    end
  end

  context "Static assets" do 
    before :all do
      create_dummy_app!
      HighFive::Config.configure do |config|
        config.root = @project_root
        config.destination = "www"
        config.assets "stylesheets"
        config.assets "public/custom_path", destination: "/"
      end
      cli(HighFive::Thor::Tasks::Deploy).deploy("web")
    end
    after(:all) { destroy_dummy_app! }

    it "should include the entire static asset directory as-is at the destination" do
      expect(File.join(@project_root, "www", "stylesheets/screen.css")).to exist
    end

    it "should respect the destination option" do
      expect(File.join(@project_root, "www", "public/custom_path")).not_to exist
      expect(File.join(@project_root, "www", "custom_app/controllers/custom_controller.js")).to exist
      expect(File.join(@project_root, "www", "custom_app.js")).to exist
    end
  end

end
