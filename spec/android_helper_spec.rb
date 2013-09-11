require 'spec_helper'

describe HighFive::AndroidHelper do
  it 'should be able to extract the project name from a build.xml' do
    name = HighFive::AndroidHelper.project_name_from_build_xml(File.join(File.dirname(__FILE__), "dummy", "build.xml"))

    name.should eq 'Fake Name'
  end
end