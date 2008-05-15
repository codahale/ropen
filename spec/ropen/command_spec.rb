require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "ropen/command"

describe Ropen::Command do
  
  before(:each) do
    @prints_stdout = fixture(:prints_stdout)
    @exits_with_error  = fixture(:exits_with_error)
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
    
    it "should yield stdin, stdout, and stderr" do
      @cmd.run do |stdin, stdout, stderr|
        stdout.read.chomp.should == "This is stdout."
        stderr.read.chomp.should == "This is stderr."
      end
    end
    
  end
  
end