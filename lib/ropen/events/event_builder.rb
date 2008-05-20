require "ropen/events"
require "ropen/events/block_event"

# TODO: document me

class Ropen::Events::EventBuilder
  
  def initialize(handler)
    @handler = handler
  end
  
  def on_start(&block)
    create_event(:on_start, block)
  end
  
  def on_finish(&block)
    create_event(:on_finish, block)
  end
  
  def on_stdout(&block)
    create_event(:on_stdout, block)
  end
  
  def on_stderr(&block)
    create_event(:on_stderr, block)
  end
  
private
  
  def create_event(method, block)
    event = Ropen::Events::BlockEvent.new
    event.send("#{method}=", block)
    @handler.register(event)
  end
  
end