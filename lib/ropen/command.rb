require "ropen"
require "ropen/events/event_builder"
require "ropen/events/event_handler"
require "ropen/pipe"
require "ropen/spool"

# TODO: add timeouts for processes stalling for lack of stdin

# The main class of Ropen, <tt>Ropen::Command</tt> encapsulates the execution of
# and iteration with a child process.
class Ropen::Command
  # The fully-qualified filename of the executable.
  attr_reader :executable
  
  # An array of arguments to be passed to the executable.
  attr_reader :arguments
  
  # The exit status of the process, or +nil+ if it has not run or terminated.
  attr_reader :exit_status
  
  # Create a new command given an +executable+ filename and an optional array of
  # +arguments+.
  # 
  #   cmd = Ropen::Command.new("cat", "-n", "/home/coda/my-recipes.txt")
  # 
  # <b>N.B.:</b> +executable+ <b>must</b> be the relative or full path of an
  # executable file. If +executable+ does not exist on disk, or the current
  # process does not have permission to execute it, a
  # <tt>Ropen::InvalidExecutableError</tt> exception will be raised.
  # 
  # @param [String] executable the filename of the executable to run
  # @param [Array] arguments optional arguments to be passed to the executable
  # @return [Ropen::Command] a command instance
  # @yield passes itself to an option block for convenient configuration
  # @raise Ropen::InvalidExecutableError raised when +executable+ is invalid
  def initialize(executable, *arguments)
    @executable = find_executable(executable)
    @arguments  = arguments
    @stdin_spool = Ropen::Spool.new
    @event_handler = Ropen::Events::EventHandler.new(self)
    @event_builder = Ropen::Events::EventBuilder.new(@event_handler)
    yield self if block_given?
  end
  
  # Executes the command, triggering any callbacks. Blocks until the child
  # process terminates.
  # 
  # @return [Process::Status] the status of the child process
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
  
  # The STDIN IO for the child process. If the process is not currently running,
  # returns a Ropen::Spool which will replay on the STDIN IO when the process
  # is executed.
  # 
  # @return [IO] STDIN for the running process
  def stdin
    @stdin_io || @stdin_spool
  end
  
  # A list of registered events which will receive callbacks when this command
  # runs.
  # 
  # @return [Array] an array of events
  def events
    @event_handler.events
  end
  
  # Adds +event+ to the end of the list of registered events.
  # 
  # @param event The event to add.
  def register_event(event)
    @event_handler.register(event)
  end
  
  # Runs a block when the child process writes to +STDOUT+.
  # 
  # @yield [Ropen::Command, String] The command being run and the data written.
  def on_stdout(&block)
    @event_builder.on_stdout(&block)
  end
  
  # Runs a block when the child process writes to +STDERR+.
  # 
  # @yield [Ropen::Command, String] The command being run and the data written.
  def on_stderr(&block)
    @event_builder.on_stderr(&block)
  end
  
  # Runs a block when the child process starts.
  # 
  # @yield [Ropen::Command] The command being run.
  def on_start(&block)
    @event_builder.on_start(&block)
  end
  
  # Runs a block when the child process terminates.
  # 
  # @yield [Ropen::Command] The command that was run.
  def on_finish(&block)
    @event_builder.on_finish(&block)
  end
  
private
  
  # Creates a new set of pipes for the input and outputs of a process.
  def initialize_streams
    @stdin  = Ropen::Pipe.new
    @stdout = Ropen::Pipe.new
    @stderr = Ropen::Pipe.new
  end
  
  # Redirects the input and output streams for a process to this instance's
  # streams.
  def redirect_streams
    @stdin.bind_writer(STDIN)
    @stdout.bind_reader(STDOUT)
    @stderr.bind_reader(STDERR)
  end
  
  # Closes the discarded portions of the open pipes. Synchronizes the STDIN
  # writer. Returns STDIN, STDOUT, and STDERR IO instances.
  # 
  # @return [Array<IO>] STDIN, STDOUT, and STDERR
  def open_streams
    @stdin.close_reader
    @stdout.close_writer
    @stderr.close_writer
    @stdin.writer.sync = true
    return [@stdin.writer, @stdout.reader, @stderr.reader]
  end
  
  # Connects the STDIN IO process, runs the events handler for STDOUT and
  # STDERR, replays messages from the STDIN spool to STDIN, and blocks until
  # the child process terminates, at which point its exit status is saved.
  def process_streams(stdin, stdout, stderr, child_pid)
    @stdin_io = stdin
    @stdin_spool.replay(stdin)
    @event_handler.run(stdout, stderr)
    Process.waitpid(child_pid)
    @exit_status = $?
    @event_handler.finish
  end
  
  # Closes any open streams, and removes the references to avoid broken pipe
  # errors.
  def finalize_streams
    [@stdin, @stdout, @stderr].each { |s| s.close }
    @stdin = nil
    @stdin_io = nil
    @stdout = nil
    @stderr = nil
  end
  
  # Finds the full filename for +executable_name+.
  # 
  # @param executable_name [String] the full or relative filename of the executable
  # @return [String] the fully qualified filename
  # @raise [Ropen::InvalidExecutableError] if the file doesn't exist or isn't executable
  def find_executable(executable_name)
    executable = File.expand_path(executable_name)
    unless File.exist?(executable)
      raise Ropen::InvalidExecutableError.new("#{executable_name} does not exist")
    end
    
    unless File.executable?(executable)
      raise Ropen::InvalidExecutableError.new("#{executable_name} is not executable")
    end
    
    return executable
  end

end