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
    call_events(:start, @command)
    def stdout.callback ; :stdout ; end
    def stderr.callback ; :stderr ; end
    streams = [stdout, stderr]
    until streams.empty?
      selected, _ = IO.select(streams, nil, nil, 0.1)
      next if selected.nil? || selected.empty?
      selected.each do |stream|
        if stream.eof? then
          streams.delete(stream)
        else
          data = stream.readpartial(1024)
          call_events(stream.callback, @command, data)
        end
      end
    end
  end
  
  def finish
    call_events(:finish, @command)
  end
  
private
  
  def call_events(m, *args)
    catch(:halt) do
      @events.each { |e| e.send(m, *args) }
    end
  end
  
end