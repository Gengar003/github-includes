require "open-uri"

class Includer
	
	def initialize(urlbase, org, repo, path, properties)
		
		@url_base = urlbase
		@organization = org
		@repository = repo
		@source_root = "#{@url_base}/#{@organization}/#{@repository}/master/#{path}"
		@property_source = properties
	end
	
	def process_file(path)
		return process_file_internal( @source_root, path, [full_path] )
	end
	
	def process_file_internal(cwd, path, trace)
		
		full_path = nil
		
		if path.start_with? "/"
			full_path = Pathname.new( path )
		else
			full_path = Pathname.new( "/#{cwd}/#{path}" )
		end
		
		if trace.include? full_path
			return prettyprint_error( "Cyclic inclusion", trace )
		end
		
		trace = Array.new( trace ) << full_path
		
		contents = ""
		
		begin
			contents = open( "#{@source_root}#{full_path}" ).read
		rescue OpenURI::HTTPError => error
			return prettyprint_error( "HTTP error while reading [#{full_path}]: [#{error.io.status}]" )
		end
		
		subbed_contents = @property_source.insert_properties( contents )
		
		contents.scan( /\#\{(.*+)\}/ ) do |match, filepath|
			subbed_contents = subbed_contents.gsub( match, process_file_internal( new_cwd, filepath, trace ) )
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
end