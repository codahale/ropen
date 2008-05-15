require File.join(File.dirname(__FILE__), "spec_helper")

require "ropen"

describe Ropen do
  it "should be a module" do
    Ropen.should be_an_instance_of(Module)
  end
end