require "ropen/events/abstract_event"

# TODO: document me

class Ropen::Events::BlockEvent < Ropen::Events::AbstractEvent
  attr_accessor :on_start, :on_stop, :on_stdout, :on_stderr
  
  def initialize
    super
    @on_start = @on_stop = @on_stdout = @on_stderr = method(:empty_event)
  end
  
  def start(cmd)
    @on_start.call(cmd)
  end
  
  def stop(cmd)
    @on_stop.call(cmd)
  end
  
  def stdout(cmd, data)
    @on_stdout.call(cmd, data)
  end
  
  def stderr(cmd, data)
    @on_stderr.call(cmd, data)
  end
  
private
  
  def empty_event(*_)
    return true
  end
  
end