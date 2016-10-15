#!/usr/bin/env ruby

require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'dotenv'

require './lib/cmd'
require './lib/directory_ensure'

Dotenv.load

# This file is just used to quickly test gems and things

filename = "THE_TRUMAN_SHOW".titleize
path = "#{ENV['PWD']}/tmp/handbrake.log"
backup_path = path.gsub ".log", "-#{filename.downcase.gsub(' ', '_')}.log"
puts "#{path} #{backup_path}"

# puts %w(Earth Fire).to_sentence

# puts ENV['VOLUMES_TO_SKIP'].split(":")
# puts ENV['SMS_NUMBER']
# puts ENV['TEMP_DIR']
# puts ENV['TARGET_DIR']

# cmd = CMD.new <<-SHELL
#   sleep 2; \
#   ls
# SHELL
#
# path = "#{ENV['PWD']}/tmp/foo.log"
# DirectoryEnsure.new path
#
# File.open(path, "w") do |file|
#   cmd.run do |_, ts, line|
#     file.puts "#{ts.strftime "%Y-%m-%d %H:%M:%S"} - #{line}"
#   end
# end
