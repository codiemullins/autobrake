#!/usr/bin/env ruby

require 'awesome_print'
require 'twilio-ruby'
require 'highline'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'dotenv'

# Setup environment
Dotenv.load
cli = HighLine.new

VOLUMES_TO_SKIP = ENV['VOLUMES_TO_SKIP'].split(":")
SMS_NUMBER = ENV['SMS_NUMBER']
TEMP_DIR = ENV['TEMP_DIR']
TARGET_DIR = ENV['TARGET_DIR']

# Require repo specific ruby files
require './lib/tracks'
require './lib/track'
require './lib/sms'
require './lib/cmd'
require './lib/directory_ensure'

def volumes
  return @_volumes if @_volumes
  @_volumes = `ls /Volumes`.split("\n").
    reject { |volume| VOLUMES_TO_SKIP.include?(volume)  }
end

volumes.each do |volume|
  dvd_info = eval(`lsdvd -Or "/Volumes/#{volume}"`)

  tracks = Tracks.new dvd_info[:track]
  feature_tracks = tracks.select { |t| t.length > 1 * 60 * 60 }

  if feature_tracks.length > 15
    cli.say "This DVD has too many tracks to automatically select one..."
    track_known = cli.ask("Do you know which track to use?") { |q| q.default = "n" }
    exit unless track_known.downcase == "y"

    chosen_track = cli.ask "Which track to rip?", Integer
    feature_tracks = feature_tracks.select { |track| track.number == chosen_track }
  end

  idx = 1
  named_tracks = feature_tracks.map do |track|
    num = "%02d" % idx

    label = (feature_tracks.length > 1) ? "Filename for #{num}: " : "Filename: "
    default_name = (feature_tracks.length > 1) ? "#{volume}_#{num}" : volume

    idx += 1
    name = cli.ask(label) { |q| q.default = default_name.titleize }
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

    puts `mv "#{temp_file}" "#{target_file}"`
    backup_path = path.gsub ".log", "-#{filename.downcase.gsub(' ', '_')}.log"
    puts `mv "#{path}" "#{backup_path}"`

  end

  `diskutil eject "/Volumes/#{volume}"`

  names = named_tracks.map { |nt| nt[:name] }
  SMS.new(SMS_NUMBER, "#{names.to_sentence} complete. Now ready to play on Plex!").send!
  puts "Sent SMS to #{SMS_NUMBER}"

end
