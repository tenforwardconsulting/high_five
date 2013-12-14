require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe HighFive::Thor::Tasks::Initialization do 
  before :each do
    @original_dir = Dir.pwd
    @project_root = Dir.mktmpdir("hi5")
    Dir.chdir @project_root
  end

  after :each do
    Dir.chdir @original_dir
    FileUtils.rm_rf @project_root
  end

  it "should create high_five.rb in the config directory" do
    ::HighFive::Thor::Tasks::Initialization.start(["init"])
    Dir.exists?(File.join(@project_root, "config")).should be_true
    File.exists?(File.join(@project_root, "config", "high_five.rb")).should be_true
    Dir.exists?(File.join(@project_root, "config", "high_five")).should be_true
    File.exists?(File.join(@project_root, "config", "high_five", "app-common.js")).should be_true
  end

end