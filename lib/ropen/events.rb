require "ropen"

# TODO: document me

class Ropen::Events
  attr_reader :callbacks
  
  def initialize
    @callbacks = []
    @running_callbacks = []
  end
  
  def on_output(&block)
    @callbacks << block
  end
  
  def run(stream)
    @thread = Thread.new do
      until stream.eof?
        data = stream.read
        @callbacks.each do |e|
          @running_callbacks << Thread.new(data, &e)
        end
      end
    end
  end
  
  def finish
    @thread.join
    @running_callbacks.each { |t| t.join }
  end
  
end