class CLI < Thor
  desc "movie", "rip DVD with movie settings"
  def movie
    Ripper.new(target_dir: "#{TARGET_DIR}/Movies").rip
  end

  option :season, aliases: :s, default: 1
  option :episode_start, aliases: :e, default: 1
  desc "show NAME", "rip TV show named NAME"
  def show name
    file_prefix = "#{name} - S#{options['season']}E"
    opts = {
      file_prefix: file_prefix,
      start_num: options['episode_start'],
      season: options['season'],
      name: name,
      target_dir: "#{TARGET_DIR}/Shows/#{name}",
      min_length: 5,
      max_length: 90
    }
    Ripper.new(opts).rip
  end
end
