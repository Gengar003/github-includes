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
GITHUB_SRCROOT = "src"
PROPERTIES_PATH = params["prop_path"]
GITHUB_PROPERTIES = "#{GITHUB_URL}/#{GITHUB_ORG}/#{GITHUB_REPO}/master/#{PROPERTIES_PATH}"
puts "properties at #{GITHUB_PROPERTIES}<hr>"
demo = Includer.new(
	GITHUB_URL,
	GITHUB_ORG,
	GITHUB_REPO,
	GITHUB_SRCROOT,
	PropertyConfigurer.new( GITHUB_PROPERTIES ) )

if params["file"].nil?
	puts "Please specify a ?file="
end

code_file = params["file"]

puts "getting #{code_file}<br/><hr>"

code_data = demo.process_file( code_file )

puts "<textarea rows='30' cols='100'>#{code_data}</textarea>"