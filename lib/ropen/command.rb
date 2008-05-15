require "ropen"

class Ropen::Command
  attr_reader :executable, :arguments
  
  def initialize(executable, *arguments)
    @executable = File.expand_path(executable)
    @arguments  = arguments
    unless File.exist?(@executable)
      raise Ropen::InvalidExecutable.new("#{executable} does not exist")
    end
    yield self if block_given?
  end
  
end