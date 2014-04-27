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
			
			if splat[1].nil?
				next
			end
			
			@properties[ splat[0] ] = splat[1].rstrip
		end
	end

	def insert_properties(file_contents, property_overrides)
		
		merged_properties = @properties.merge( property_overrides )
		modded = file_contents
		
		file_contents.scan( /(\$\{([^\s}]+)(\s[^}]+)?\})/ ) do |match, key, default|

			if merged_properties.include?( key )
				modded = modded.gsub( /#{Regexp.quote( match )}/, merged_properties[ key ] )
			elsif !default.nil?
				modded = modded.gsub( /#{Regexp.quote( match )}/, default.lstrip )
			end
			
		end

		return modded
	end
end
