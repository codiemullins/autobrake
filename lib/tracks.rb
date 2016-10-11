require './lib/track'

class Tracks
  include Enumerable

  def initialize tracks
    @tracks = tracks.map { |track| Track.new(track) }
  end

  def each &block
    @tracks.each &block
  end
end
