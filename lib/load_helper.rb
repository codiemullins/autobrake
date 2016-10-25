LIB = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(LIB) unless $LOAD_PATH.include?(LIB)

require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'awesome_print'
require 'dotenv'
require 'fileutils'
require 'highline/import'
require 'open3'
require 'thor'
require 'twilio-ruby'

# Setup environment
Dotenv.load

VOLUMES_TO_SKIP = (ENV['VOLUMES_TO_SKIP'] || '').split(":")
SMS_NUMBER = ENV['SMS_NUMBER']
TEMP_DIR = ENV['TEMP_DIR']
TARGET_DIR = ENV['TARGET_DIR']
MIN_TRACK_LENGTH = ENV['MIN_TRACK_LENGTH'].nil? ? 60 : ENV['MIN_TRACK_LENGTH'].to_i
MAX_TRACK_LENGTH = ENV['MAX_TRACK_LENGTH'].nil? ? 900 : ENV['MAX_TRACK_LENGTH'].to_i

# Require repo specific ruby files
require 'autobrake/cli'
require 'autobrake/cmd'
require 'autobrake/directory_ensure'
require 'autobrake/ripper'
require 'autobrake/rip_track'
require 'autobrake/sms'
require 'autobrake/track'
require 'autobrake/tracks'
require 'autobrake/volumes'
