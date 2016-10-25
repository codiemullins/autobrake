class Ripper
  attr_reader :file_prefix, :start_num, :volume, :min_length, :max_length, :temp_dir, :target_dir

  def initialize opts = {}
    @volume = Volumes.new.list(VOLUMES_TO_SKIP).first
    @file_prefix = opts[:file_prefix]
    @start_num = opts[:start_num] || 1
    @min_length = opts[:min_length] || MIN_TRACK_LENGTH
    @max_length = opts[:max_length] || MAX_TRACK_LENGTH
    @temp_dir = opts[:temp_dir] || TEMP_DIR
    @target_dir = opts[:target_dir] || TARGET_DIR
  end

  def rip
    say "Found #{feature_tracks.count} that are longer than #{min_length} and less than #{max_length} minutes..."
    choose_tracks
    name_tracks
    rip_tracks
    eject_disk
    send_sms
  end

  def choose_tracks
    return @_chosen_tracks if @_chosen_tracks
    case feature_tracks.length
    when 0
      puts "No tracks found, exiting..."
      exit
    when proc { |n| n > 15 }
      say "This DVD has too many tracks to automatically select one..."
      track_known = ask("Do you know which track to use?") { |q| q.default = "n" }
      exit unless track_known.downcase == "y"

      chosen_track = ask "Which track to rip?", Integer
      @_chosen_tracks = feature_tracks.select { |track| track.number == chosen_track }
    else
      @_chosen_tracks = feature_tracks
    end
  end

  def name_tracks
    return @_name_tracks if @_name_tracks
    chosen_tracks = choose_tracks
    idx = start_num
    @_name_tracks = chosen_tracks.map do |track|
      num = "%02d" % idx
      if file_prefix
        name = "#{file_prefix}#{num}"
      else
        label = (chosen_tracks.length > 1) ? "Filename for #{num}: " : "Filename: "
        default_name = (chosen_tracks.length > 1) ? "#{volume}_#{num}" : volume
        name = ask(label) { |q| q.default = default_name.titleize }
      end

      idx += 1
      {
        track: track,
        name: name
      }
    end
  end

  def rip_tracks
    name_tracks.each do |named_track|
      puts "Ripping Track #{named_track[:track].number}, #{named_track[:name]}..."
      RipTrack.new(named_track[:track], named_track[:name], volume, temp_dir, target_dir).rip
      puts "Finished Ripping Track #{named_track[:track].number}, #{named_track[:name]}"
    end
  end

  def eject_disk
    `diskutil eject "/Volumes/#{volume}"`
  end

  def send_sms
    names = name_tracks.map { |nt| nt[:name] }
    complete_time = Time.now
    minutes = ((complete_time - start_time) / 60).round
    SMS.new(SMS_NUMBER, "#{names.to_sentence} complete. Completed in #{minutes} minutes.").send!
    puts "Sent SMS to #{SMS_NUMBER}"
  end

  def dvd_info
    eval(`lsdvd -Or "/Volumes/#{volume}"`)
  end

  def tracks
    @_tracks ||= Tracks.new dvd_info[:track]
  end

  def feature_tracks
    @_feature_tracks ||= tracks.select { |t| t.length > (60 * min_length) && t.length < (60 * max_length) }
  end
end
