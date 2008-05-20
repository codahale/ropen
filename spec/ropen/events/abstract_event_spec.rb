require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

require "ropen/events/abstract_event"

describe Ropen::Events::AbstractEvent do
  before(:each) do
    @cmd, @data = mock(:cmd), mock(:data)
    @event = Ropen::Events::AbstractEvent.new
  end
  
  it "should do nothing on starting" do
    lambda { @event.start(@cmd) }.should_not throw_symbol(:halt)
  end
  
  it "should do nothing on finishing" do
    lambda { @event.finish(@cmd) }.should_not throw_symbol(:halt)
  end
  
  it "should do nothing on stdout output" do
    lambda { @event.stdout(@cmd, @data) }.should_not throw_symbol(:halt)
  end
  
  it "should do nothing on stderr output" do
    lambda { @event.stderr(@cmd, @data) }.should_not throw_symbol(:halt)
  end
  
end