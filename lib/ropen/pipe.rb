require "ropen"

# TODO: add events
# TODO: add reading/writing

class Ropen::Pipe
  attr_reader :reader, :writer
  
  def initialize
    @reader, @writer = IO.pipe
  end
  
  def bind_output(stream)
    swap_streams(stream, @reader, @writer)
  end
  
  def bind_input(stream)
    swap_streams(stream, @writer, @reader)
  end
  
  def close
    close_reader
    close_writer
  end
  
  def close_reader
    @reader.close unless @reader.closed?
  end
  
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