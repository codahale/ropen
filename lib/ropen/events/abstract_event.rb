require "ropen/events"

# An abstract base class for Ropen events. Descendents of this class can use the
# template method pattern to easily add callbacks for events.
class Ropen::Events::AbstractEvent
  
  # An event called when the child process is started.
  # 
  # @param [Ropen::Command] command The command instance that has started.
  # @return [Boolean] If +false+, the callback chain is halted.
  def start(command)
    return true
  end
  
  # An event called when the child process has finished.
  # 
  # @param [Ropen::Command] command The command instance that has finished.
  # @return [Boolean] If +false+, the callback chain is halted.
  def finish(command)
    return true
  end
  
  # An event called when the child process writes to +STDOUT+.
  # 
  # @param [Ropen::Command] command The command instance that is running.
  # @param [String] data The output of the child process on +STDOUT+.
  # @return [Boolean] If +false+, the callback chain is halted.
  def stdout(command, data)
    return true
  end
  
  # An event called when the child process writes to +STDERR+.
  # 
  # @param [Ropen::Command] command The command instance that is running.
  # @param [String] data The output of the child process on +STDERR+.
  # @return [Boolean] If +false+, the callback chain is halted.
  def stderr(command, data)
    return true
  end
  
end