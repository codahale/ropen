require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "ropen/spool"

describe Ropen::Spool do
  
  before(:each) do
    @spool = Ropen::Spool.new
    @stream = mock(:stream)
  end
  
  it "should collect messages and replay them on an object once" do
    block = lambda { @stream.do_it }
    @spool.puts "I'm a message."
    @spool.close
    @spool.run_this_thing(&block)
    
    @stream.should_receive(:puts).with("I'm a message.")
    @stream.should_receive(:close)
    @stream.should_receive(:do_it)
    @stream.should_receive(:run_this_thing).with(&block).and_yield
    
    @spool.replay(@stream)
  end
  
end