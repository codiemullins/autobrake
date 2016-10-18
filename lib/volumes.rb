class Volumes
  def initialize path = '/Volumes'
    @path = path
  end

  def list ignore_directories = []
    return @_volumes if @_volumes
    @_volumes = `ls "#{@path}"`.split("\n").reject { |volume| ignore_directories.include? volume  }
  end
end
