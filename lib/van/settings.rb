# frozen_string_literal: true
# lib/van/settings
# load and parse settings.

begin
	require 'kdl'
rescue LoadError => e
	raise "kdl could not be loaded (is it installed?): #{e.message}"
end

module Van

	# parses a kdl file into a kdl document Object.
	# returns nil if it's false. Also assumes that the file is exists.
	# an optional silence_warnings parameter is set to false. This is used for
	# testing.
	def self.parse_kdl(config_file = nil, silence_warnings = false)
		# kdl_string = File.open(config_file).read
		begin
			kdl_string = File.open(config_file).read
		rescue => error # Errno::ENOENT
			puts ""
			puts "Error trying to read a config file: \"#{error}.\""
			puts "  Current directory: #{Dir.pwd}"
			puts "  files in directory: #{Dir.glob('*')}"
			puts ""
		end

		begin
			kdl_doc = KDL.parse_document(kdl_string)
		rescue => error
			warn "#{error}"
			# parse error message to get line number and column:
			message = Camping::GuideBook.kdl_error_message(kdl_string, error.message, error)
			m = error.message.match( /\((\d)+:(\d)\)/ )
			line, column = m[1].to_i, m[2].to_i

			warn("\nError parsing config: #{config_file}, on line: #{line}, at column: #{column}.", message, "#{error.message}", uplevel: 1) unless silence_warnings
		end

		kdl_doc
	end

	# #get_config
	# searches for any kdl document inside of a db folder.
	# Then parses it looking for a database node. The Database node
	# contains database settings for different environments.
	# Example syntax:
	#
	#    database {
	#     default adapter="sqlite3" database="db/camping.db" host="localhost" pool=5 timeout=5000
	#     development
	#     production adapter="postgres" database=""
	#    }
	#
	# This can probably be refactored down to something more simple.
	def self.get_config(provided_config_file = nil)

		config_file = provided_config_file
		config_file = self.get_config_file unless provided_config_file

		kdl_doc = nil
		kdl_doc = self.parse_kdl(config_file)

		# database settings dictionary
		db_sets = self.map_kdl(kdl_doc)

		# This merges the default data from the config file, or our lib defaults
		# into each environment. If no kdl default is found then our lib defaults
		# are used.
		new_sets, dfault = {}, db_sets[:default] ||= self.db_defaults[:default]
		db_sets.each { |d| new_sets[d[0]] = dfault.merge(d[1]) }
		new_sets
	end

end
