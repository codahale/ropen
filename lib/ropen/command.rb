require "ropen"
require "ropen/events"
require "ropen/pipe"
require "ropen/spool"

# TODO: document me
# TODO: add timeouts for processes stalling for lack of stdin

class Ropen::Command
  attr_reader :executable, :arguments, :exit_status
  
  def initialize(executable, *arguments)
    @executable = File.expand_path(executable)
    @arguments  = arguments
    check_executable(executable)
    @stdout_events = Ropen::Events.new
    @stderr_events = Ropen::Events.new
    @stdin_spool = Ropen::Spool.new
    yield self if block_given?
  end
  
  def run
    initialize_streams
    pid = fork do
      redirect_streams
      exec(@executable, *@arguments)
    end
    stdin, stdout, stderr = open_streams
    process_streams(stdin, stdout, stderr, pid)
    return @exit_status
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
  
  def open_streams
    @stdin.close_reader
    @stdout.close_writer
    @stderr.close_writer
    @stdin.writer.sync = true
    return [@stdin.writer, @stdout.reader, @stderr.reader]
  end
  
  def redirect_streams
    @stdin.bind_input(STDIN)
    @stdout.bind_output(STDOUT)
    @stderr.bind_output(STDERR)
  end
  
  def process_streams(stdin, stdout, stderr, child_pid)
    @stdin_io = stdin
    @stdout_events.run(stdout)
    @stderr_events.run(stderr)
    @stdin_spool.replay(stdin)
    [@stdout_events, @stderr_events].each { |e| e.finish }
    Process.waitpid(child_pid)
    @exit_status = $?
  end
  
  def finalize_streams
    [@stdin, @stdout, @stderr].each { |s| s.close }
    @stdin = nil
    @stdin_io = nil
    @stdout = nil
    @stderr = nil
  end
  
  def check_executable(executable_name)
    unless File.exist?(@executable)
      raise Ropen::InvalidExecutableError.new("#{executable_name} does not exist")
    end
    
    unless File.executable?(@executable)
      raise Ropen::InvalidExecutableError.new("#{executable_name} is not executable")
    end
  end

end