require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "ropen/pipe"

describe Ropen::Pipe do
  
  before(:each) do
    @reader = stub(:reader, :close => nil, :closed? => false)
    @writer = stub(:writer, :close => nil, :closed? => false)
    IO.stub!(:pipe).and_return([@reader, @writer])
    @pipe = Ropen::Pipe.new
  end
  
  it "should create a new IO pipe" do
    IO.should_receive(:pipe).and_return([@reader, @writer])
    pipe = Ropen::Pipe.new
    pipe.reader.should == @reader
    pipe.writer.should == @writer
  end
  
  it "should bind a writer to a stream" do
    @pipe.reader.should_receive(:close)
    STDOUT.should_receive(:reopen).with(@pipe.writer)
    @pipe.writer.should_receive(:close)
    @pipe.bind_reader(STDOUT)
  end
  
  it "should bind a reader to a stream" do
    @pipe.writer.should_receive(:close)
    STDIN.should_receive(:reopen).with(@pipe.reader)
    @pipe.reader.should_receive(:close)
    
    @pipe.bind_writer(STDIN)
  end
  
  it "should close the reader" do
    @reader.should_receive(:closed?).and_return(true)
    @reader.should_not_receive(:close)
    @pipe.close_reader
  end
  
  it "should close the writer" do
    @writer.should_receive(:closed?).and_return(false)
    @writer.should_receive(:close)
    @pipe.close_writer
  end
  
  it "should close both reader and writer" do
    @reader.should_receive(:closed?).and_return(true)
    @reader.should_not_receive(:close)
    @writer.should_receive(:closed?).and_return(false)
    @writer.should_receive(:close)
    @pipe.close
  end
  
end
