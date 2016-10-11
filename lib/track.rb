class Track
  def initialize track
    @track = track
  end

  def length
    @track[:length]
  end

  def length_to_s
    Time.at(length).utc.strftime("%H:%M:%S")
  end

  def number
    @track[:ix]
  end

  def vts_id
    @track[:vts_id]
  end
end
