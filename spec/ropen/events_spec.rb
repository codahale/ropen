require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "singleton"

require "ropen/events"

class ThreadSafeStorage
  include Singleton
  attr_reader :stuff
  
  def initialize
    @stuff = []
  end
  
end

describe Ropen::Events do
  
  before(:each) do
    @stream = mock(:stream)
    @events = Ropen::Events.new
  end
  
  it "should collect events" do
    callback = lambda { |line| puts line }
    @events.on_output(&callback)
    @events.callbacks.should == [callback]
  end
  
  it "should run collected events in parallel" do
    @stream.should_receive(:eof?).and_return(false, false, true)
    @stream.should_receive(:readpartial).with(an_instance_of(Numeric)).and_return("blah", "blee")
    
    @events.on_output do |line|
      ThreadSafeStorage.instance.stuff << [1, line]
      sleep 1
    end
    
    @events.on_output do |line|
      ThreadSafeStorage.instance.stuff << [2, line]
      sleep 2
    end
    
    start_time = Time.now
    @events.run(@stream)
    @events.finish
    elapsed_time = Time.now - start_time
    elapsed_time.should < 2.1
    elapsed_time.should > 1.9
    ThreadSafeStorage.instance.stuff.transpose.last.should == ["blah", "blah", "blee", "blee"]
  end
  
end