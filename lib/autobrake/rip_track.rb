class RipTrack
  attr_reader :track, :name, :volume, :temp_dir, :target_dir, :path

  def initialize track, name, volume, temp_dir, target_dir
    @track = track
    @name = name
    @volume = volume
    @temp_dir = temp_dir
    @target_dir = target_dir
    @path = "#{ENV['PWD']}/tmp/handbrake.log"
  end

  def rip
    execute_handbrake do |file, ts, line|
      file.puts "#{ts.strftime "%Y-%m-%d %H:%M:%S"} - #{line}"
    end
    move_target
    move_log
  end

  private

  def filename
    "#{name}.m4v"
  end

  def temp_file
    "#{temp_dir}/#{filename}"
  end

  def target_file
    "#{target_dir}/#{filename}"
  end

  def execute_handbrake
    DirectoryEnsure.new path
    File.open(path, "w") do |file|
      handbrake.run do |_, ts, line|
        yield file, ts, line
      end
    end
  end

  def move_target
    DirectoryEnsure.new target_file
    puts `mv "#{temp_file}" "#{target_file}"`
  end

  def move_log
    backup_path = path.gsub ".log", "-#{filename.downcase.gsub(' ', '_')}.log"
    puts `mv "#{path}" "#{backup_path}"`
  end

  def handbrake
    CMD.new <<-SHELL
      /usr/local/bin/HandBrakeCLI -Z High Profile \
        -i "/Volumes/#{volume}" \
        -o "#{temp_file}" \
        -s "1,2,3,4,5,6" \
        -t #{track.number}
    SHELL
  end
end
