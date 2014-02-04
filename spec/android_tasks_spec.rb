require 'spec_helper'
require 'chunky_png'

describe HighFive::Thor::Tasks::AndroidTasks do
  include HighFive::TestHelper
  include HighFive::AndroidHelper

  before(:all) do
    create_dummy_app!
    HighFive::Config.configure do |config|
      config.root = @project_root
      config.destination = "www"
      config.platform :android do |android|
        android.destination = 'android/assets/www'
      end
    end
  end

  after(:all) do
    destroy_dummy_app!
  end

  context 'Set icon' do
    let(:drawable_dir) { File.join(@project_root, 'android', 'res') }
    before(:all) do
      cli(HighFive::Thor::Tasks::AndroidTasks).set_icon File.join(@project_root, 'test_icon.png')
    end

    it 'creates icons for each drawable- folder' do
      valid_directories(drawable_dir).each do |dir|
        file = File.join(dir, 'icon.png')
        expect(file).to exist
      end
    end

    it 'creates default in drawable folder' do
      file = File.join(drawable_dir, 'drawable', 'icon.png')
      expect(file).to exist
    end

    it 'resizes to correct dimensions' do
      valid_directories(drawable_dir).each do |dir|
        res = parse_resolution(dir)
        size = res_map[res]
        file = File.join(dir, 'icon.png')
        image = ChunkyPNG::Image.from_file(file)
        expect(image.dimension.height).to eq size
        expect(image.dimension.width).to eq size
      end
    end
  end

  context "Set version" do
    it 'updates version number' do
      cli(HighFive::Thor::Tasks::AndroidTasks, version: '2.0').set_version
      manifest = File.read(File.join(@project_root, 'android', 'AndroidManifest.xml'))
      expect(manifest).to match(/android:versionName="2.0"/)
    end
  end
end
