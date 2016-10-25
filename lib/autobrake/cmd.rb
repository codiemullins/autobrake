class CMD
  attr_reader :command

  def initialize command
    @command = command
  end

  def run
    Open3.popen3(command) do |stdin, stdout, stderr, thread|
      { out: stdout, err: stderr}.each do |std_type, stream|
        Thread.new do
          until (raw_line = stream.gets).nil? do
            parsed_line = raw_line.gsub("\n", "")
            yield std_type, Time.now, parsed_line
          end
        end
      end

      thread.join
    end
  end
end
