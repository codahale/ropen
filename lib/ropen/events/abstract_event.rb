require "ropen/events"

# An abstract base class for Ropen events. Descendents of this class can use the
# template method pattern to easily add callbacks for events.
class Ropen::Events::AbstractEvent
  
  # An event called when the child process is started.
  # 
  # @param [Ropen::Command] command The command instance that has started.
  # @throw [Symbol] If +:halt+, the callback chain is halted.
  def start(command)
    # called when the process starts
  end
  
  # An event called when the child process has finished.
  # 
  # @param [Ropen::Command] command The command instance that has finished.
  # @throw If +:halt+, the callback chain is halted.
  def finish(command)
    # called when the process finishes
  end
  
  # An event called when the child process writes to +STDOUT+.
  # 
  # @param [Ropen::Command] command The command instance that is running.
  # @param [String] data The output of the child process on +STDOUT+.
  # @throw If +:halt+, the callback chain is halted.
  def stdout(command, data)
    # called when the process writes to STDOUT
  end
  
  # An event called when the child process writes to +STDERR+.
  # 
  # @param [Ropen::Command] command The command instance that is running.
  # @param [String] data The output of the child process on +STDERR+.
  # @throw If +:halt+, the callback chain is halted.
  def stderr(command, data)
    # called when the process writes to STDERR
  end
  
end