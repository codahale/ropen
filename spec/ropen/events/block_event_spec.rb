require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

require "ropen/events/block_event"

describe Ropen::Events::BlockEvent do
  
  before(:each) do
    @cmd, @data = mock(:cmd), mock(:data)
    @event = Ropen::Events::BlockEvent.new
  end
  
  it "should call its on_start block when started" do
    @cmd.should_receive(:stdin).and_return(@cmd)
    @cmd.should_receive(:puts).with("dingo")
    @event.on_start = lambda { |cmd| cmd.stdin.puts("dingo") }
    lambda { @event.start(@cmd) }.should_not throw_symbol(:halt)
  end
  
  it "should not halt when started without an on_start block" do
    lambda { @event.start(@cmd) }.should_not throw_symbol(:halt)
  end
  
  it "should call its on_stop block when stopped" do
    @cmd.should_receive(:stdin).and_return(@cmd)
    @cmd.should_receive(:puts).with("dingo")
    @event.on_finish = lambda { |cmd| cmd.stdin.puts("dingo") }
    lambda { @event.finish(@cmd) }.should_not throw_symbol(:halt)
  end
  
  it "should not halt when stopped without an on_stop block" do
    lambda { @event.finish(@cmd) }.should_not throw_symbol(:halt)
  end
  
  it "should call its on_stdout block when given stdout output" do
    @cmd.should_receive(:stdin).and_return(@cmd)
    @cmd.should_receive(:puts).with(@data)
    @event.on_stdout = lambda { |cmd, data| cmd.stdin.puts(data) }
    lambda { @event.stdout(@cmd, @data) }.should_not throw_symbol(:halt)
  end
  
  it "should not halt when given stdout output without an on_stdout block" do
    lambda { @event.stdout(@cmd, @data) }.should_not throw_symbol(:halt)
  end
  
  it "should call its on_stderr block when given stderr output" do
    @cmd.should_receive(:stdin).and_return(@cmd)
    @cmd.should_receive(:puts).with(@data)
    @event.on_stderr = lambda { |cmd, data| cmd.stdin.puts(data) }
    lambda { @event.stderr(@cmd, @data) }.should_not throw_symbol(:halt)
  end
  
  it "should not halt when given stderr output without an on_stderr block" do
    lambda { @event.stderr(@cmd, @data) }.should_not throw_symbol(:halt)
  end
  
end