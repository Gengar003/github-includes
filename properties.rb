require "open-uri"

class PropertyConfigurer
	def initialize(url_to_property_file)

		@properties = Hash.new
		
		prop_file = open(url_to_property_file).read
		
		prop_file.lines do |line|
			splat = line.split("=",2)
			@properties[ splat[0] ] = splat[1]
		end
	end

	def insert_properties(file_contents)
		
		modded = file_contents
		
		@properties.each do |key, value|
			modded = modded.gsub(/\$\{#{key}\}/, value)
		end

		return modded
	end
end
