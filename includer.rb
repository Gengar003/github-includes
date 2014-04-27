require "open-uri"
require "pathname"

class Includer
	
	def initialize(urlbase, org, repo, path, properties)
		
		@url_base = urlbase
		@organization = org
		@repository = repo
		@source_root = "#{@url_base}/#{@organization}/#{@repository}/master/#{path}"
		@property_source = properties
	end
	
	def process_file(path)
		return process_file_internal( @source_root, path, [figure_full_path( "/", path )], Hash.new )
	end
	
	def process_file_internal(cwd, path, trace, property_overrides)
		
		full_path = figure_full_path( cwd, path )
		new_cwd = full_path.dirname
		
		if trace.include? full_path
			return prettyprint_error( "Cyclic inclusion", trace )
		end
		
		trace = Array.new( trace ) << full_path
		
		contents = ""
		
		file_url = "#{@source_root}#{full_path}"
		
		begin
			contents = open( file_url ).read
		rescue OpenURI::HTTPError => error
			return prettyprint_error( "HTTP error while reading [#{full_path}]: [#{error.io.status}]", trace )
		rescue URI::InvalidURIError => error
			return prettyprint_error( "Invalid URL for an included file: [#{file_url}]", trace )
		end
		
		subbed_contents = @property_source.insert_properties( contents, property_overrides )
		subbed_contents_copy = String.new( subbed_contents )
		
		subbed_contents_copy.scan( /(^[\t ]*)?(\#\{([^ }]+)\s?([^}]*)?\})/ ) do |whitespace, match, filepath, properties|

			spacing = ""
			
			if whitespace =~ /^\s*$/
				spacing = whitespace
			end
			
			merged_properties = property_overrides
			
			if !properties.nil?
				
				merged_properties = Hash.new
				merged_properties = merged_properties.merge( property_overrides )
				
				properties.scan( /([^=]+)="(.*)"/ ) do |key, value|
					
					if value.nil?
						value = ""
					end
					
					merged_properties[ key ] = value.rstrip
				end
			end
			
			includable_file = process_file_internal( new_cwd, filepath, trace, merged_properties )
			
			indented_file = includable_file.gsub( /\n(.+)/, "\n#{spacing}\\1" )
			
			subbed_contents = subbed_contents.gsub( /#{Regexp.quote( match )}/, indented_file )
		end
		
		return subbed_contents
		
	end
	
	def prettyprint_error(message, trace)
		error = "// ERROR: #{message}"
		
		trace.each do |backtrace|
			error = "#{error}\n//\tfrom #{backtrace} in"
		end
		
		return error
	end
	
	def figure_full_path(cwd, path)
		
		if path.start_with? "/"
			return Pathname.new( path )
		else
			return Pathname.new( "/#{cwd}/#{path}" )
		end
	end
end
