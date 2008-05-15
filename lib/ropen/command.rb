require "ropen"

class Ropen::Command
  attr_reader :executable, :arguments
  
  def initialize(executable, *arguments)
    @executable = File.expand_path(executable)
    @arguments  = arguments
    unless File.exist?(@executable)
      raise Ropen::InvalidExecutable.new("#{executable} does not exist")
    end
    yield self if block_given?
  end
  
  def run
    initialize_streams
    pid = fork do
      # child
      sub_pid = fork do
        # grandchild
	@stdin_write.close
	STDIN.reopen(@stdin_read)
	@stdin_read
        
	@stdout_read.close
	STDOUT.reopen(@stdout_write)
	@stdout_write.close
        
	@stderr_read.close
	STDERR.reopen(@stderr_write)
	@stderr_write.close
        
	exec(@executable, *@arguments)
      end
      Process.waitpid(sub_pid)
      exit!($?.exitstatus)
    end
    # TODO: Wrap these bad boys in something comfortable.
    stdin, stdout, stderr = open_streams(pid)
    exit_status = $?.exitstatus
    yield stdin, stdout, stderr if block_given?
    return exit_status
  ensure
    finalize_streams
  end
  
private
  
  def initialize_streams
    @stdin_read,  @stdin_write  = IO::pipe
    @stdout_read, @stdout_write = IO::pipe
    @stderr_read, @stderr_write = IO::pipe
  end
  
  def open_streams(pid)
    @stdin_read.close
    @stdout_write.close
    @stderr_write.close
    Process.waitpid(pid)
    @stdin_write.sync = true
    return [@stdin_write, @stdout_read, @stderr_read]
  end
  
  def finalize_streams
    [
      @stdin_read, @stdin_write,
      @stdout_read, @stdout_write,
      @stderr_read, @stderr_write
    ].compact.each { |s| s.close unless s.closed? }
  end
  
end