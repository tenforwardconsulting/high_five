require 'spec_helper'

describe HighFive::IosHelper do
  it 'should be able to extract a UUID from a mobileprovision file' do
    uuid = HighFive::IosHelper.uuid_from_mobileprovision(File.join(File.dirname(__FILE__), "dummy", "fake.mobileprovision"))

    uuid.should eq 'THIS-IS-A-FAKE-UUID'
  end
end