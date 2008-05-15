require "ropen"

# TODO: document me

class Ropen::Spool
  def initialize
    @messages = []
  end
  
  def method_missing(m, *args, &block)
    @messages << [m, args, block]
  end
  
  def replay(stream)
    while message = @messages.shift
      m, args, block = message
      stream.send(m, *args, &block)
    end
  end
end