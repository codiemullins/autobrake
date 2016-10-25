bin_file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require "#{File.expand_path('../lib', bin_file)}/load_helper.rb"

Pry.config.color = true
