Ropen
=====

A process execution library which doesn't suck.

      cmd = Ropen::Command.new("/bin/cat", "/home/coda/my-recipes.txt")
      cmd.on_stdout do |cat, line|
        if line =~ /sugar/
          puts line
        end
        cat.stdin.puts "cat doesn't take input, but imagine if it did..."
      end
      cmd.run

