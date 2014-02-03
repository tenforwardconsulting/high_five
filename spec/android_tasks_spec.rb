require 'spec_helper'
require 'chunky_png'

describe HighFive::Thor::Tasks::AndroidTasks do
  include HighFive::TestHelper

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
      cli = HighFive::Thor::Tasks::AndroidTasks.new([])
      cli.instance_variable_set("@base_config", HighFive::Config.instance)
      cli.set_icon File.join(@project_root, 'test_icon.png')
    end

    it 'creates icons for each drawable- folder' do
      Dir.glob(File.join(drawable_dir, "drawable-*")) do |dir|
        file = File.join(dir, 'icon.png')
        expect(file).to exist
      end
    end

    it 'creates default in drawable folder' do
      file = File.join(drawable_dir, 'drawable', 'icon.png')
      expect(file).to exist
    end

    it 'resizes to correct dimensions' do
      res_map ={
        ldpi: 36,
        mdpi: 48,
        hdpi: 72,
        xhdpi: 96,
        default: 512
      }
      Dir.glob(File.join(drawable_dir, "drawable-*")) do |dir|
        file = File.join(dir, 'icon.png')
        image = ChunkyPNG::Image.from_file(file)
        res = dir.gsub(/.*\//, '').gsub('drawable-', '').to_sym
        size = res_map[res]
        expect(image.dimension.height).to eq size
        expect(image.dimension.width).to eq size
      end
    end
  end

  context "Set version" do
    it 'updates version number' do
      cli = HighFive::Thor::Tasks::AndroidTasks.new([], {version: '2.0'})
      cli.instance_variable_set("@base_config", HighFive::Config.instance)
      cli.set_version
      manifest = File.read(File.join(@project_root, 'android', 'AndroidManifest.xml'))
      expect(manifest).to match /android:versionName="2.0"/
    end
  end
end
