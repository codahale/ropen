require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "ropen/events"

describe Ropen::Events do
  it "should be a module" do
    Ropen::Events.should be_an_instance_of(Module)
  end
end