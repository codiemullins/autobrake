require 'awesome_print'
require 'twilio-ruby'
require 'highline'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'dotenv'

# Setup environment
Dotenv.load
cli = HighLine.new

VOLUMES_TO_SKIP = ENV['VOLUMES_TO_SKIP'].split(":")
SMS_NUMBER = ENV['SMS_NUMBER']
TEMP_DIR = ENV['TEMP_DIR']
TARGET_DIR = ENV['TARGET_DIR']
MIN_TRACK_LENGTH = ENV['MIN_TRACK_LENGTH'].nil? ? 60 : ENV['MIN_TRACK_LENGTH'].to_i

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Require repo specific ruby files
require 'tracks'
require 'track'
require 'sms'
require 'cmd'
require 'directory_ensure'
require 'volumes'
