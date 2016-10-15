#!/usr/bin/env ruby

require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'dotenv'

Dotenv.load

# This file is just used to quickly test gems and things

# puts "THE_TRUMAN_SHOW".titleize
#
# puts %w(Earth Fire).to_sentence

puts ENV['VOLUMES_TO_SKIP'].split(":")
puts ENV['SMS_NUMBER']
puts ENV['TEMP_DIR']
puts ENV['TARGET_DIR']
