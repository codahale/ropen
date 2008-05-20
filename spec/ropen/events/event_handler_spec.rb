require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

require "ropen/events/event_handler"

describe Ropen::Events::EventHandler do
  
  before(:each) do
    @stdout = mock(:stdout)
    @stderr = mock(:stderr)
    @command = mock(:event)
    @event = mock(:event)
    @handler = Ropen::Events::EventHandler.new(@command)
  end
  
  it "should register events" do
    @handler.register(@event)
    @handler.register(@event)
    @handler.events.should == [@event, @event]
  end
  
  it "should run events on the output of a stream" do
    @event.should_receive(:start).ordered
    @event.should_receive(:stdout).with(@command, "blah").ordered
    @event.should_receive(:stdout).with(@command, "blee").ordered
    @event.should_receive(:stderr).with(@command, "ERROR").ordered
    @event.should_receive(:finish).ordered
    
    @stdout.should_receive(:eof?).and_return(false, false, true)
    @stdout.should_receive(:readpartial).with(an_instance_of(Numeric)).and_return("blah", "blee")
    
    @stderr.should_receive(:eof?).and_return(false, true)
    @stderr.should_receive(:readpartial).with(an_instance_of(Numeric)).and_return("ERROR")
    
    @handler.register(@event)
    @handler.run(@stdout, @stderr)
    @handler.finish
  end
  
end