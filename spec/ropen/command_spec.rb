require File.join(File.dirname(__FILE__), "..", "spec_helper")

require "ropen/command"

describe Ropen::Command do
  
  before(:each) do
    @prints_stdout = fixture(:prints_stdout)
    @full_prints_stdout = File.expand_path(@prints_stdout)
  end
  
  describe "initializing" do
    
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
end