require 'open3'

class CMD
  def initialize prefix, command
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      while line=stdout.gets do
        puts "#{prefix}: #{line}"
      end
      while line=stderr.gets do
        puts "#{prefix}:ERROR: #{line}"
      end
    end

    puts "Complete!"
  end
end
