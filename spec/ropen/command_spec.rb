require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "ropen/command"

describe Ropen::Command do
  
  before(:each) do
    @prints_stdout = fixture(:prints_stdout)
    @exits_with_error  = fixture(:exits_with_error)
    @asks_for_name = fixture(:asks_for_name)
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
    
    it "should raise a Ropen::InvalidExecutable if the executable doesn't exist" do
      lambda {
        Ropen::Command.new("bleepblorp")
      }.should raise_error(Ropen::InvalidExecutable, "bleepblorp does not exist")
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
      @cmd.stdout.on_output do |line|
        line.should == "This is stdout.\n"
      end
      @cmd.stderr.on_output do |line|
        line.should == "This is stderr.\n"
      end
      @cmd.run
    end
    
  end
  
  describe "running an executable which requires input" do
    
    before(:each) do
      @cmd = Ropen::Command.new(@asks_for_name)
    end
    
    it "should allow data to be written on stdin" do
      @cmd.stdout.on_output do |line|
        line.should == "You entered: MONGO\n"
      end
      @cmd.stderr.on_output do |line|
        if line =~ /Enter your name/
          @cmd.stdin.puts "MONGO"
          @cmd.stdin.flush
        end
      end
      @cmd.run
    end
    
    it "should timeout after a specified period of waiting for input" do
      
    end
    
  end
  
end