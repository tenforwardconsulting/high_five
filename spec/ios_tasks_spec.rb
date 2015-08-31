require 'spec_helper'
require 'chunky_png'

describe HighFive::Thor::Tasks::Ios do
  include HighFive::TestHelper
  include HighFive::IosHelper

  before(:all) do
    create_dummy_app!
    HighFive::Config.configure do |config|
      config.root = @project_root

      config.destination = "www"
      config.platform :ios do |ios|
        ios.destination = 'ios/www'
      end
    end
  end

  after(:all) do
    destroy_dummy_app!
  end

  context "Set version" do
    it 'updates version number' do
      cli(HighFive::Thor::Tasks::Ios, version: '2.0').set_version
      plist = File.read(File.join(@project_root, 'ios', 'Info.plist'))
      expect(plist).to match(/<key>CFBundleShortVersionString<\/key>\s+<string>2.0<\/string>/)
    end
  end

  context "set_property" do
    it 'updates changes a property' do
      cli(HighFive::Thor::Tasks::Ios, key: 'Api Endpoint', value: 'https://api.different.com').set_property
      plist = File.read(File.join(@project_root, 'ios', 'Info.plist'))
      expect(plist).to match(/<key>Api Endpoint<\/key>\s+<string>https:\/\/api.different.com<\/string>/)
    end

    it 'adds a new property' do
            cli(HighFive::Thor::Tasks::Ios, key: 'New Property', value: 'test').set_property
      plist = File.read(File.join(@project_root, 'ios', 'Info.plist'))
      expect(plist).to match(/<key>New Property<\/key>\s+<string>test<\/string>/)
    end
  end
end
