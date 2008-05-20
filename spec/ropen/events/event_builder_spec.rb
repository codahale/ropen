require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

require "ropen/events/event_builder"
require "ropen/events/event_handler"

describe Ropen::Events::EventBuilder do
  
  before(:each) do
    @command = mock(:command)
    @handler = Ropen::Events::EventHandler.new(@command)
    @builder = Ropen::Events::EventBuilder.new(@handler)
  end
  
  it "should build events with start callbacks" do
    callback = lambda { |cmd| cmd.dingo }
    @builder.on_start(&callback)
    @handler.events.size == 1
    @handler.events.first.should be_an_instance_of(Ropen::Events::BlockEvent)
    @handler.events.first.on_start.should == callback
  end
  
  it "should build events with finish callbacks" do
    callback = lambda { |cmd| cmd.dingo }
    @builder.on_finish(&callback)
    @handler.events.size == 1
    @handler.events.first.should be_an_instance_of(Ropen::Events::BlockEvent)
    @handler.events.first.on_finish.should == callback
  end
  
  it "should build events with stdout callbacks" do
    callback = lambda { |cmd, data| cmd.puts(data) }
    @builder.on_stdout(&callback)
    @handler.events.size == 1
    @handler.events.first.should be_an_instance_of(Ropen::Events::BlockEvent)
    @handler.events.first.on_stdout.should == callback
  end
  
  it "should build events with stderr callbacks" do
    callback = lambda { |cmd, data| cmd.puts(data) }
    @builder.on_stderr(&callback)
    @handler.events.size == 1
    @handler.events.first.should be_an_instance_of(Ropen::Events::BlockEvent)
    @handler.events.first.on_stderr.should == callback
  end
  
end