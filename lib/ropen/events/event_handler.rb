require "ropen/events"

# TODO: document me

class Ropen::Events::EventHandler
  attr_reader :events
  
  def initialize(command)
    @command = command
    @events  = []
    @threads = []
  end
  
  def register(event)
    @events << event
  end
  
  def run(stdout, stderr)
    call_events(:start)
    handle_output(stdout, :stdout)
    handle_output(stderr, :stderr)
  end
  
  # Blocks until the threads started by #run completes.
  def finish
    @threads.each { |t| t.join }
    call_events(:finish)
    @threads.clear
  end
  
private
  
  def call_events(m, *args)
    catch(:halt) do
      @events.each { |e| e.send(m, *args) }
    end
  end
  
  def handle_output(stream, callback_method)
    @threads << Thread.new do
      until stream.eof?
        data = stream.readpartial(1024) # TODO: smaller buffer?
        call_events(callback_method, @command, data)
      end
    end
  end
  
end