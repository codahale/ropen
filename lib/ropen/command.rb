require "ropen"
require "ropen/events"
require "ropen/pipe"
require "ropen/spool"

# TODO: document me

class Ropen::Command
  attr_reader :executable, :arguments, :exit_status
  
  def initialize(executable, *arguments)
    @executable = File.expand_path(executable)
    @arguments  = arguments
    unless File.exist?(@executable)
      raise Ropen::InvalidExecutableError.new("#{executable} does not exist")
    end
    @stdout_events = Ropen::Events.new
    @stderr_events = Ropen::Events.new
    @stdin_spool = Ropen::Spool.new
    yield self if block_given?
  end
  
  def run
    initialize_streams
    pid = fork do
      @stdin.bind_input(STDIN)
      @stdout.bind_output(STDOUT)
      @stderr.bind_output(STDERR)
      exec(@executable, *@arguments)
    end
    stdin, stdout, stderr = open_streams(pid)
    @stdin_io = stdin
    @stdout_events.run(stdout)
    @stderr_events.run(stderr)
    @stdin_spool.replay(stdin)
    [@stdout_events, @stderr_events].each { |e| e.finish }
    Process.waitpid(pid)
    return @exit_status = $?
  ensure
    finalize_streams
  end
  
  def stdin
    @stdin_io || @stdin_spool
  end
  
  def stdout
    @stdout_events
  end
  
  def stderr
    @stderr_events
  end
  
private
  
  def initialize_streams
    @stdin  = Ropen::Pipe.new
    @stdout = Ropen::Pipe.new
    @stderr = Ropen::Pipe.new
  end
  
  def open_streams(pid)
    @stdin.close_reader
    @stdout.close_writer
    @stderr.close_writer
#    Process.waitpid(pid)
    @stdin.writer.sync = true
    return [@stdin.writer, @stdout.reader, @stderr.reader]
  end
  
  def finalize_streams
    [@stdin, @stdout, @stderr].each { |s| s.close }
    @stdin = nil
    @stdin_io = nil
    @stdout = nil
    @stderr = nil
  end
  
end