require "open-uri"

class PropertyConfigurer
	def initialize(url_to_property_file)

		@properties = Hash.new
		
		prop_file = open(url_to_property_file).read
		
		prop_file.lines do |line|
			
			if line.nil?
				next
			end
			
			splat = line.split("=",2)
			@properties[ splat[0] ] = splat[1].rstrip
		end
	end

	def insert_properties(file_contents, property_overrides)
		
		merged_properties = @properties.merge( property_overrides )
		modded = file_contents
		
		file_contents.scan( /(\$\{([^\s]+)\s?(.*+)?\})/ ) do |match, key, default|
			
			if merged_properties.include?( key )
				modded = modded.gsub( Regex.quote( match ), Regex.quote( merged_properties[ key ] ) )
			elsif !default.nil?
				modded = modded.gsub( Regex.quote( match ), Regex.qoute( default ) )
			end
			
		end

		return modded
	end
end
