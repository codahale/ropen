# The Ropen namespace. All the excitement is in <tt>Ropen::Command</tt>.
module Ropen
  # An exception raised when the executable is not a valid executable.
  class InvalidExecutableError < StandardError; end
  # An exception raised when the execution takes too long.
  class TimeoutError < StandardError; end
end