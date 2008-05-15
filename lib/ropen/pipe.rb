require "ropen"

# A bidirectional IO pipe wrapper.
class Ropen::Pipe
  # An +IO+ instance from which the output of the pipe can be read.
  attr_reader :reader
  # An +IO+ instance to which the input of the pipe can be written.
  attr_reader :writer
  
  # Creates a new Ropen::Pipe with a unconnected +reader+ and +writer+.
  def initialize
    @reader, @writer = IO.pipe
  end
  
  # Binds the pipe's +reader+ to +stream+ and closes the +writer+ to make it a
  # read-only pipe (e.g., +STDOUT+ or +STDERR+).
  def bind_reader(stream)
    swap_streams(stream, @reader, @writer)
  end
  
  # Binds the pipe's +writer+ to +stream+ and closes the +reader+ to make it a
  # write-only pipe (e.g., +STDIN+).
  def bind_writer(stream)
    swap_streams(stream, @writer, @reader)
  end
  
  # Closes both the +reader+ and +writer+, if either are open.
  def close
    close_reader
    close_writer
  end
  
  # Closes the +reader+ if it is open.
  def close_reader
    @reader.close unless @reader.closed?
  end
  
  # Closes the +writer+ if it is open.
  def close_writer
    @writer.close unless @writer.closed?
  end
  
private
  
  def swap_streams(stream, to_close, to_reopen)
    to_close.close
    stream.reopen(to_reopen)
    to_reopen.close
  end
  
end