class DirectoryEnsure
  def initialize path
    dirname = File.dirname(path)

    unless File.directory? dirname
      FileUtils.mkdir_p dirname
    end
  end
end
