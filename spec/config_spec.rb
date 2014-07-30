require 'spec_helper'

describe HighFive::Config do

  describe '#build_platform_config' do
    it 'raises error when given platform that is not in config' do
      HighFive::Config.configure do |config|
        config.root = "/"
        config.asset_paths = ["assets"]
      end
      config = HighFive::Config.instance
      expect {
        config.build_platform_config 'foobar'
      }.to raise_error
    end
  end

  context "asset_paths" do
    before do
      HighFive::Config.configure do |config|
        config.root = "/"
        config.asset_paths = ["assets"]
        config.platform :android do |android|

        end
      end
      @config = HighFive::Config.instance
    end
    it "should keep track of asset_paths for platform configs" do
      platform_config = @config.build_platform_config('android')
      platform_config.asset_paths.should eq ["assets"]
    end
  end

  context "settings" do
    before do
      HighFive::Config.configure do |config|
        config.root = "/"
        config.setting base_url: "http://example.com/api"
        config.environment :production do |production|
          production.setting base_url: "http://production.example.com/api"
        end

        config.platform :android do |android|
          android.setting base_url: "http://android.example.com"
          android.environment :production do |android_production|
            android_production.setting base_url: "http://android-production.example.com"
          end
        end
      end
      @config = HighFive::Config.instance
    end

    it "should serialize all the settings to json" do
      @config.high_five_javascript.should eq %q(<script type="text/javascript">if(typeof(window.HighFive)==='undefined'){window.HighFive={};}window.HighFive.Settings={"base_url":"http://example.com/api"};</script>)
    end

    example "platform settings should take precedence" do
      prod = @config.build_platform_config :production
      prod.js_settings[:base_url].should eq "http://production.example.com/api"
    end

    it "should handle nested settings properly" do
      android_production = @config.build_platform_config(:platform).build_platform_config(:android)
      android_production.js_settings[:base_url].should eq "http://android-production.example.com"
    end

  end

  context "environment configuration" do
    before do
      HighFive::Config.configure do |config|
        config.root = "/"
        config.setting base_url: "http://example.com/api"
        config.platform :android do |android|
          android.assets "android_asset"
          android.setting android_flag: true
        end
        config.environment :production do |production|
          production.assets "production_asset"
          production.setting base_url: "http://production.example.com/api"
        end
      end
      @config = HighFive::Config.instance
    end

    it "inherits from platforms" do
      config = @config.build_platform_config(:android).build_platform_config(:production)
      config.static_assets.should include "android_asset"
      config.static_assets.should include "production_asset"
    end

    it "doesn't care about the inherit order" do
      config = @config.build_platform_config(:production).build_platform_config(:android)
      config.static_assets.should include "android_asset"
      config.static_assets.should include "production_asset"
    end

    it "merges settings" do
      config = @config.build_platform_config(:android).build_platform_config(:production)
      config.js_settings.should be_has_key(:base_url)
      config.js_settings.should be_has_key(:android_flag)
    end

    it "sets minify to true by default for production environments" do
      config = @config.build_platform_config('android').build_platform_config('production')
      config.minify.should eq :uglifier
      config = @config.build_platform_config(:production).build_platform_config(:android)
      config.minify.should eq :uglifier
    end
  end

  context "easy settings" do
    before do
      HighFive::Config.configure do |config|
        config.root = "/"
        config.asset_paths = ["assets"]
        config.dev_index "default.html"
        config.platform :web do |web|
          web.dev_index "index-debug.html"
        end
      end
      @config = HighFive::Config.instance
    end

    it "should keep track of dev_index" do
      @config.dev_index.should eq "default.html"
    end

    it "should override dev_index on a platform" do
      platform_config = @config.build_platform_config('web')
      platform_config.dev_index.should eq "index-debug.html"
    end
  end

  context "nested settings" do
    before do
      HighFive::Config.configure do |config|
        config.root = "/"
        config.setting base_url: "http://example.com/api"
        config.platform :ios do |ios|

        end
        config.platform :android do |android|
          android.assets "android_asset"
          android.setting android_flag: true
          config.environment :production do |android_production|
            android_production.setting base_url: "http://android-production.example.com/api"
          end
        end
        config.environment :production do |production|
          production.assets "production_asset"
          production.setting base_url: "http://production.example.com/api"
        end
      end
      @config = HighFive::Config.instance
    end

    it "should use the environment setting if none is specified" do
      platform_config = @config.build_platform_config('ios').build_platform_config('production')
      platform_config.js_settings[:base_url].should eq "http://production.example.com/api"
    end

    it "should allow platforms to specifically override environment settings" do
      platform_config = @config.build_platform_config('android').build_platform_config('production')
      platform_config.js_settings[:base_url].should eq "http://android-production.example.com/api"
    end

  end

end
