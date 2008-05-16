require "ropen"

# TODO: would halting the callback chain make any sense?
# TODO: expand this to include non-block events, and start/stop messages
# TODO: split this into Event/EventHandler/EventBuilder

# An event builder for accumulating and processing output events for STDOUT and
# STDERR streams of running processes.
class Ropen::Events
  # An array of existing callback procs.
  attr_reader :callbacks
  
  # A string containing the accumulated output on the handled stream.
  attr_reader :output
  
  # Creates a new Ropen::Events instance.
  def initialize
    @callbacks = []
    @output = ""
  end
  
  # Registers an output callback to be run when the process outputs data to the
  # specified stream.
  # 
  # @yield [String] the data output on the specified stream
  def on_output(&block)
    @callbacks << block if block
  end
  
  # Runs the callbacks specified via +on_output+ on +stream+ in a separate
  # thread. Returns immediately.
  # 
  # @param [IO, #eof?, #readpartial] data stream to run events on
  def run(stream)
    @thread = Thread.new do
      until stream.eof?
        data = stream.readpartial(1024) # TODO: smaller buffer?
        @output << data
        @callbacks.each do |e|
          e.call(data)
        end
      end
    end
  end
  
  # Blocks until the thread started by #run completes.
  def finish
    @thread.join
  end
  
end