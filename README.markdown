Ropen
=====

A process execution library which doesn't suck.

      cmd = Ropen::Command.new("/bin/cat", "/home/coda/my-recipes.txt")
      cmd.stdout.on_output do |line|
        if line =~ /sugar/
          puts line
        end
        cmd.stdin.puts "cat doesn't take input, but imagine if it did..."
      end
      cmd.run

