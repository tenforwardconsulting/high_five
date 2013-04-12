require 'spec_helper'

describe HighFive::Config do 

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

end