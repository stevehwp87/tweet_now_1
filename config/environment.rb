# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'

require 'uri'
require 'pathname'
require 'daybreak'
require 'yaml'
require 'uri'
require 'json'
require 'pg'
require 'active_record'
require 'logger'

require 'sinatra'
require "sinatra/reloader" if development?

require 'erb'
require 'twitter'
require 'byebug'

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }

DATABASE = File.expand_path(File.dirname(__FILE__) + '/db/signin.db')
TWITTER = File.expand_path(File.dirname(__FILE__) + "/twitter_oauth.yml")
# TWITTER = YAML::load_file(TWITTER_PATH)
API_KEYS = YAML::load(File.open(TWITTER))
# Set up the database and models
# byebug
require APP_ROOT.join('config', 'database')
require APP_ROOT.join('lib', 'twitter_sign_in.rb')

# $client = Twitter::REST::Client.new do |config|
# config.consumer_key = TWITTER["consumer_key"]
# config.consumer_secret = TWITTER["consumer_secret"]
# end

configure do
  # the usage of sessions here is very simple, in your app you should implement a proper storage for it.
  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => 'your_secret'
  # setting a random secret
end

TwitterSignIn.configure