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
  
  def pretend_to_run_stream
    File.open(fixture("stdout.txt")) do |f1|
      File.open(fixture("stderr.txt")) do |f2|
        @handler.run(f1, f2)
        @handler.finish
      end
    end
  end
  
  it "should run events on the output of STDOUT and STDERR" do
    @handler.register(@event)
    @event.should_receive(:start).with(@command).ordered
    @event.should_receive(:stdout).with(@command, "Blah\nBlah").ordered
    @event.should_receive(:stderr).with(@command, "Blee").ordered
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