require "ropen"

# A recorder/replayer for messages sent to a receiver. Allows clients to spool a
# series of messages which can then be sent in order to a specified receiver.
# 
# ==== Examples
#   
#   receiver = "You "
#   spool = Ropen::Spool.new
#   spool << " and me."
#   spool.upcase!
#   spool.replay(receiver)
#   receiver #=> "YOU AND ME."
#   
class Ropen::Spool
  
  # Creates a new, empty spool.
  def initialize
    @messages = []
  end
  
  # Registers the method call as a message to send to the eventual receiver.
  def method_missing(m, *args, &block)
    @messages << [m, args, block]
  end
  
  # Sends all spooled messages to +receiver+, in order. Once a message is sent,
  # it's removed from the spool.
  def replay(receiver)
    while message = @messages.shift
      m, args, block = message
      receiver.send(m, *args, &block)
    end
  end
end