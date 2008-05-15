require "ropen"

# TODO: document me
# TODO: would halting the callback chain make any sense?

class Ropen::Events
  attr_reader :callbacks, :output
  
  def initialize
    @callbacks = []
    @output = ""
  end
  
  def on_output(&block)
    @callbacks << block
  end
  
  def run(stream)
    @thread = Thread.new do
      until stream.eof?
        data = stream.readpartial(1024)
        @output << data
        @callbacks.each do |e|
          e.call(data)
        end
      end
    end
  end
  
  def finish
    @thread.join
  end
  
end