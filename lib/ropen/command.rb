require "ropen"
require "ropen/pipe"
require "ropen/events"

# TODO: document me

class Ropen::Command
  attr_reader :executable, :arguments, :exit_status, :stdin
  
  def initialize(executable, *arguments)
    @executable = File.expand_path(executable)
    @arguments  = arguments
    unless File.exist?(@executable)
      raise Ropen::InvalidExecutable.new("#{executable} does not exist")
    end
    @stdout_events = Ropen::Events.new
    @stderr_events = Ropen::Events.new
    yield self if block_given?
  end
  
  def run
    initialize_streams
    pid = fork do
      # child
      sub_pid = fork do
        # grandchild
        @stdin.bind_input(STDIN)
        @stdout.bind_output(STDOUT)
        @stderr.bind_output(STDERR)
	exec(@executable, *@arguments)
      end
      Process.waitpid(sub_pid)
      exit!($?.exitstatus)
    end
    stdin, stdout, stderr = open_streams(pid)
    @stdout_events.run(stdout)
    @stderr_events.run(stderr)
    yield stdin, stdout, stderr if block_given?
    [@stdout_events, @stderr_events].each { |e| e.finish }
    return @exit_status = $?
  ensure
    finalize_streams
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
    Process.waitpid(pid)
    @stdin.writer.sync = true
    return [@stdin.writer, @stdout.reader, @stderr.reader]
  end
  
  def finalize_streams
    [@stdin, @stdout, @stderr].each { |s| s.close }
  end
  
end