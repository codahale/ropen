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
  
  it "should run collected events on a given stream" do
    output = []
    
    @stream.should_receive(:eof?).and_return(false, false, true)
    @stream.should_receive(:readpartial).with(an_instance_of(Numeric)).and_return("blah", "blee")
    
    @events.on_output do |line|
      output << [1, line]
    end
    
    @events.on_output do |line|
      output << [2, line]
    end
    
    @events.run(@stream)
    @events.finish
    
    output.transpose.last.should == ["blah", "blah", "blee", "blee"]
  end
  
end