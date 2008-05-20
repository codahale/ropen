require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

require "ropen/events/abstract_event"

describe Ropen::Events::AbstractEvent do
  before(:each) do
    @cmd, @data = mock(:cmd), mock(:data)
    @event = Ropen::Events::AbstractEvent.new
  end
  
  it "should do nothing on starting" do
    @event.start(@cmd).should == true
  end
  
  it "should do nothing on finishing" do
    @event.finish(@cmd).should == true
  end
  
  it "should do nothing on stdout output" do
    @event.stdout(@cmd, @data).should == true
  end
  
  it "should do nothing on stderr output" do
    @event.stderr(@cmd, @data).should == true
  end
  
end