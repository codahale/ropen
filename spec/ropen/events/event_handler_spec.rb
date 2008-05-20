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
  
  def pretend_to_run_stream
    @stdout.should_receive(:eof?).and_return(false, false, true)
    @stdout.should_receive(:readpartial).with(an_instance_of(Numeric)).and_return("blah", "blee")
    
    @stderr.should_receive(:eof?).and_return(false, true)
    @stderr.should_receive(:readpartial).with(an_instance_of(Numeric)).and_return("ERROR")
    
    @handler.register(@event)
    @handler.run(@stdout, @stderr)
    @handler.finish
  end
  
  it "should register events" do
    @handler.register(@event)
    @handler.register(@event)
    @handler.events.should == [@event, @event]
  end
  
  it "should run events on the output of a stream" do
    @event.should_receive(:start).with(@command).ordered
    @event.should_receive(:stdout).with(@command, "blah").ordered
    @event.should_receive(:stdout).with(@command, "blee").ordered
    @event.should_receive(:stderr).with(@command, "ERROR").ordered
    @event.should_receive(:finish).with(@command).ordered
    
    pretend_to_run_stream
  end
  
  it "should catch all thrown halts" do
    @event.should_receive(:start).any_number_of_times.and_throw(:halt)
    @event.should_receive(:stdout).any_number_of_times.and_throw(:halt)
    @event.should_receive(:stderr).any_number_of_times.and_throw(:halt)
    @event.should_receive(:finish).any_number_of_times.and_throw(:halt)
    
    pretend_to_run_stream
  end
  
end