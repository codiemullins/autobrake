#!/usr/bin/env ruby

cwd = File.expand_path('../', __FILE__)
$LOAD_PATH.unshift(cwd) unless $LOAD_PATH.include?(cwd)

require 'load_helper.rb'

Volumes.new.list(VOLUMES_TO_SKIP).each do |volume|
  dvd_info = eval(`lsdvd -Or "/Volumes/#{volume}"`)

  tracks = Tracks.new dvd_info[:track]
  feature_tracks = tracks.select { |t| t.length > (1 * 60 * MIN_TRACK_LENGTH) && t.length < (1 * 60 * MAX_TRACK_LENGTH) }

  CLI.say "Found #{feature_tracks.count} that are longer than #{MIN_TRACK_LENGTH} and less than #{MAX_TRACK_LENGTH} minutes..."

  case feature_tracks.length
  when 0
    puts "No tracks found, exiting..."
    exit
  when proc { |n| n > 15 }
    CLI.say "This DVD has too many tracks to automatically select one..."
    track_known = CLI.ask("Do you know which track to use?") { |q| q.default = "n" }
    exit unless track_known.downcase == "y"

    chosen_track = CLI.ask "Which track to rip?", Integer
    feature_tracks = feature_tracks.select { |track| track.number == chosen_track }
  end

  idx = 1
  named_tracks = feature_tracks.map do |track|
    num = "%02d" % idx

    label = (feature_tracks.length > 1) ? "Filename for #{num}: " : "Filename: "
    default_name = (feature_tracks.length > 1) ? "#{volume}_#{num}" : volume

    idx += 1
    name = CLI.ask(label) { |q| q.default = default_name.titleize }
    {
      track: track,
      name: name
    }
  end

  named_tracks.each do |named_track|
    track = named_track[:track]
    name = named_track[:name]

    filename = "#{name}.m4v"
    temp_file = "#{TEMP_DIR}/#{filename}"
    target_file = "#{TARGET_DIR}/#{filename}"

    handbrake_cmd = CMD.new <<-SHELL
      /usr/local/bin/HandBrakeCLI -Z High Profile \
        -i "/Volumes/#{volume}" \
        -o "#{temp_file}" \
        -s "1,2,3,4,5,6" \
        -t #{track.number}
    SHELL

    path = "#{ENV['PWD']}/tmp/handbrake.log"
    DirectoryEnsure.new path

    File.open(path, "w") do |file|
      handbrake_cmd.run do |_, ts, line|
        file.puts "#{ts.strftime "%Y-%m-%d %H:%M:%S"} - #{line}"
        puts line
      end
    end

    DirectoryEnsure.new target_file
    puts `mv "#{temp_file}" "#{target_file}"`
    backup_path = path.gsub ".log", "-#{filename.downcase.gsub(' ', '_')}.log"
    puts `mv "#{path}" "#{backup_path}"`

  end

  `diskutil eject "/Volumes/#{volume}"`

  names = named_tracks.map { |nt| nt[:name] }
  SMS.new(SMS_NUMBER, "#{names.to_sentence} complete. Now ready to play on Plex!").send!
  puts "Sent SMS to #{SMS_NUMBER}"

end
