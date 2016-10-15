require 'open3'

class CMD
  def initialize prefix, command
    Open3.popen3(command) do |stdin, stdout, stderr, thread|
      { out: stdout, err: stderr}.each do |key, stream|
        Thread.new do
          until (raw_line = stream.gets).nil? do
            parsed_line = Hash[timestamp: Time.now, line: "#{raw_line}"]
            puts "#{prefix}:#{key}: #{parsed_line}"
          end
        end
      end

      thread.join
    end

    puts "Complete!"
  end
end
