require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "ropen/command"

describe Ropen::Command do
  
  before(:each) do
    @prints_stdout = fixture(:prints_stdout)
    @exits_with_error  = fixture(:exits_with_error)
    @asks_for_name = fixture(:asks_for_name)
    @processes_data = fixture(:processes_data)
    @unexecutable = fixture(:unexecutable)
  end
  
  describe "initializing" do
    
    before(:each) do
      @full_prints_stdout = File.expand_path(@prints_stdout)
    end
    
    it "should expand the path of the given executable" do
      File.should_receive(:expand_path).with(@prints_stdout).and_return(@full_prints_stdout)
      cmd = Ropen::Command.new(@prints_stdout)
      cmd.executable.should == @full_prints_stdout
    end
    
    it "should raise a Ropen::InvalidExecutableError if the executable doesn't exist" do
      lambda {
        Ropen::Command.new("bleepblorp")
      }.should raise_error(Ropen::InvalidExecutableError, "bleepblorp does not exist")
    end
    
    it "should raise a Ropen::InvalidExecutableError if the executable isn't executable" do
      lambda {
        Ropen::Command.new(@unexecutable)
      }.should raise_error(Ropen::InvalidExecutableError, "./spec/fixtures/unexecutable.rb is not executable")
    end
    
    it "should accept a set of arguments" do
      cmd = Ropen::Command.new(@prints_stdout, "--color", "fleagle")
      cmd.arguments.should == ["--color", "fleagle"]
    end
    
    it "should allow for additional configuration via a block" do
      args = nil
      Ropen::Command.new(@prints_stdout, "--color", "fleagle") do |cmd|
        args = cmd.arguments
      end
      args.should == ["--color", "fleagle"]
    end
  end
  
  describe "running a simple executable" do
    
    before(:each) do
      @cmd = Ropen::Command.new(@exits_with_error)
    end
    
    it "should return the process' exit status" do
      @cmd.run.exitstatus.should == 1
      @cmd.exit_status.should_not be(:success)
    end
    
    it "should call events placed on output streams" do
      @cmd.on_stdout do |cmd, line|
        cmd.should == @cmd
        line.should == "This is stdout.\n"
      end
      @cmd.on_stderr do |cmd, line|
        cmd.should == @cmd
        line.should == "This is stderr.\n"
      end
      @cmd.run
    end
    
  end
  
  describe "running an executable which requires input in response to something" do
    
    before(:each) do
      @cmd = Ropen::Command.new(@asks_for_name)
    end
    
    it "should allow data to be written on stdin" do
      stdout = ""
      @cmd.on_stdout do |cmd, line|
        cmd.should == @cmd
        stdout << line
      end
      
      @cmd.on_stderr do |cmd, line|
        cmd.should == @cmd
        if line =~ /Enter your name/
          cmd.stdin.puts "MONGO"
          cmd.stdin.flush
        end
      end
      
      @cmd.run
      stdout.should == "You entered: MONGO\n"
    end
    
    it "should timeout after a specified period of waiting for input" do
      pending("timeout support")
#      lambda { @cmd.run }.should raise_error(Ropen::TimeoutError)
    end
    
  end
  
  describe "running an execuable which requires input first" do
    
    before(:each) do
      @cmd = Ropen::Command.new(@processes_data)
    end
    
    it "should write input to the app before any output is recorded" do
      stdout_lines = ""
      @cmd.on_stdout do |cmd, line|
        cmd.should == @cmd
        stdout_lines << line
      end
      
      stderr_lines = ""
      @cmd.on_stderr do |cmd, line|
        cmd.should == @cmd
        stderr_lines << line
      end
      
      @cmd.on_start do |cmd|
        cmd.stdin.puts "test3"
        cmd.stdin.close
      end
      
      @cmd.stdin.puts "test1"
      @cmd.stdin.puts "test2"
      
      
      @cmd.on_finish do |cmd|
        cmd.exit_status.exitstatus.should == 2
      end
      
      @cmd.run.exitstatus.should == 2
      
      stdout_lines.split("\n").should == ["TEST1", "TEST2", "TEST3"]
      stderr_lines.split("\n").should == ["Input: \"test1\\n\"", "Input: \"test2\\n\"", "Input: \"test3\\n\""]
    end
    
  end
  
  describe "running an executable via an event class" do
    
    class ProcessingData < Ropen::Events::AbstractEvent
      def start(cmd)
	cmd.stdin.puts("yay")
        cmd.stdin.close
      end
      
      def stdout(cmd, data)
	data.should == "YAY\n"
      end
    end
    
    before(:each) do
      @event = ProcessingData.new
      @cmd = Ropen::Command.new(@processes_data)
    end
    
    it "should register the event" do
      @cmd.register_event(@event)
      @cmd.events.should include(@event)
    end
    
    it "should run the executable and pass callbacks to the event" do
      @cmd.register_event(@event)
      @cmd.run
    end
  end
  
end