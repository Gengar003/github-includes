#!/usr/local/rvm/rubies/ruby-2.1.0/bin/ruby
require "rack"
require "open-uri"
require_relative "properties"
require_relative "includer"

puts "content-type:text/html"
puts ""

params = Rack::Utils.parse_nested_query( ENV["QUERY_STRING"] )

GITHUB_URL = "https://raw.githubusercontent.com"
GITHUB_ORG = params["org"]
GITHUB_REPO = params["repo"]
GITHUB_SRCROOT = "/src"
GITHUB_PROPERTIES = "#{GITHUB_URL}/#{GITHUB_ORG}/#{GITHUB_REPO}/master/properties/defaults.properties"

demo = Includer.new(
	GITHUB_URL,
	GITHUB_ORG,
	GITHUB_REPO,
	GITHUB_SRCROOT,
	PropertyConfigurer.new( GITHUB_PROPERTIES ) )

if params["script"].nil?
	puts "Please specify a ?script="
end

script = params["script"]

puts "getting #{script}<br/><hr>"

main_lsl = demo.process_file( script )

puts main_lsl