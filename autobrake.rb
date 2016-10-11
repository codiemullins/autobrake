#!/usr/bin/env ruby

require 'awesome_print'
require 'twilio-ruby'
require 'highline'
require 'active_support/core_ext/string'

require './lib/tracks'
require './lib/track'
require './lib/sms'

def volumes
  return @_volumes if @_volumes
  @_volumes = `ls /Volumes`.split("\n").reject { |volume| volume == "Macintosh HD" }
end

SMS_NUMBER = '918-894-0623'
TEMP_DIR   = '/Users/codiemullins/Desktop'
TARGET_DIR = '/Users/codiemullins/Desktop/Movies'

cli = HighLine.new

volumes.each do |volume|
  dvd_info = eval(`lsdvd -Or "/Volumes/#{volume}"`)

  tracks = Tracks.new dvd_info[:track]
  feature_tracks = tracks.select { |t| t.length > 1 * 60 * 60 }

  idx = 1
  target_names = feature_tracks.map do |track|
    num = "%02d" % idx

    label = (feature_tracks.length > 1) ? "Filename for #{track}: " : "Filename: "
    default_name = (feature_tracks.length > 1) ? "#{volume}_#{num}" : volume
    cli.ask(label) { |q| q.default = default_name.titleize }

    idx += 1
  end

  feature_tracks.each_with_index do |track, idx|
    num = "%02d" % (idx + 1)

    name = target_names[idx]
    filename = "#{name}.m4v"
    temp_file = "#{TEMP_DIR}/#{filename}"
    target_file = "#{TARGET_DIR}/#{filename}"

    puts `/usr/local/bin/HandBrakeCLI -Z High Profile \
      -i "/Volumes/#{volume}" \
      -o "#{temp_file}" \
      -s "1,2,3,4,5,6" \
      -t #{track.number}`

    puts `mv "#{temp_file}" "#{target_file}"`

    `diskutil eject /Volumes/#{volume}`

    SMS.new(SMS_NUMBER, "Movie #{name} is ripped and ready to play on Plex!").send!
    puts "Sent SMS to #{SMS_NUMBER}"
  end


end
