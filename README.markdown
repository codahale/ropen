Ropen
=====

A process execution library which doesn't suck.

      cmd = Ropen::Command.new("/bin/cat", "/home/coda/my-recipes.txt")
      cmd.on_stdout do |output|
        line = output.read.chomp
        if line =~ /sugar/
          puts line
        end
      end
