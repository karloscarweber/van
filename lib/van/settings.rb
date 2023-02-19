# frozen_string_literal: true
# lib/van/settings
# load and parse settings.

begin
	require 'kdl'
rescue LoadError => e
	raise "kdl could not be loaded (is it installed?): #{e.message}"
end

module Van

	# this is the private settings for database defaults.
	def self.db_defaults
		{
			default: {
				adapter:  'sqlite3',
				user:  'root',
				password:  'root',
				host:  'localhost',
				port:  5432,
				database:  'db/camping.db',
				max_connections:  5,
				logger: nil
			}
		}
	end

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
			puts "  Attempted to open: #{config_file}"
			puts "  Current directory: #{Dir.pwd}"
			puts "  files in directory: #{Dir.glob('*')}"
			puts ""
		end

		begin
			kdl_doc = KDL.parse_document(kdl_string)
		rescue => error
			warn "#{error}"
			# parse error message to get line number and column:
			message = Van.kdl_error_message(kdl_string, error.message, error)
			m = error.message.match( /\((\d)+:(\d)\)/ )

			if m == nil
				puts "there are no messages. #{error}"
			else
				puts "what up dog"
			end

			line, column = m[1].to_i, m[2].to_i

			warn("\nError parsing config: #{config_file}, on line: #{line}, at column: #{column}.", message, "#{error.message}", uplevel: 1) unless silence_warnings
		end

		kdl_doc
	end

	def self.map_kdl(kdl_doc=nil)
		# database settings dictionary
		db_sets = {}
		if kdl_doc
			kdl_doc.nodes.each do |d|

				# Only care about the database node
				if d.name == "database"
					# parse database
					d.children.each do |en|

						env_name = en.name.to_sym

						# parse the settings for each environment
						db_sets[env_name] = {}
						en.properties.each do |key, value|
							db_sets[env_name][key.to_sym] = value.value
						end
					end
				end

			end
		else
			# puts "No KDL document found"
		end
		db_sets
	end

	# #get_config
	# searches for any kdl document inside of a db folder.
	# Then parses it looking for a database node. The Database node
	# contains database settings for different environments.
	# Example syntax:
	#
	#    database {
	#     default adapter="sqlite3" database="db/camping.db" host="localhost" max_connections=5 timeout=5000
	#     development
	#     production adapter="postgres" database=""
	#    }
	#
	# This can probably be refactored down to something more simple.
	def self.get_config(provided_config_file = nil)

		config_file = provided_config_file
		config_file = get_config_file() unless provided_config_file != nil

		# If the config file is just nil then we probably don't have one.
		if config_file == nil
			return nil
		end

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

	# get kdl files
	# returns the config file
	# param[search_pattern] is optional, but defaults to look everywhere it can.
	# returns nil if there is nothing to find.
	def self.get_config_file(search_pattern = "**/db/*.kdl")
		# get file location,
		files = Dir.glob(search_pattern)

		config_file = nil
		# try to get the config_file for db.
		files.each do |file|
			f = file.split("/").first
			l = file.split("/").last

			# This logic prioritizes the db/config file in the root directory, This
			# assumes that a Deep search is conducted and that more than one kdl
			# file was found. Otherwise a deep, specific search will probably get
			# the specific file you want.
			if config_file != nil
				cff = config_file.split("/").first
				if f == "db" && cff != "db"
					config_file = file if l == "config.kdl"
				end
			else
				config_file = file if l == "config.kdl"
			end

		end

		config_file
	end

	# squash settings basically collapses all the settings that we have into something
	# truly beautiful.
	# It also observes what's going on with ENV['environment'] and loads the settings
	# based on the environment: development, production, test.
	def self.squash_settings(app)

		defaults = self.db_defaults

		stored_config = self.get_config
		environment = ENV['environment'] ||= "development"

		if stored_config == nil
			# Maybe add a warning here
			# puts "No Config file found, using defaults."
			stored_config = defaults
		end

		# ('postgres://user:password@host:port/database_name')
		# ('adapter://username:password@host:port/database_name')

		# The defaults are all for local hosting.
		host            = defaults[:default][:host]
		adapter         = defaults[:default][:adapter]
		database        = defaults[:default][:database]
		max_connections = defaults[:default][:max_connections]
		user            = defaults[:default][:user]
		password        = defaults[:default][:password]
		port            = defaults[:default][:port]
		logger          = defaults[:default][:logger]

		# Loop through environments set in the config.kdl file.
		# Settings that are set in app.options take precedence to whatever is set
		# in cb/config.kdl Also because defaults are already set above, they are
		# only replaced if there is a value, no value, no replacement.
		case environment
		when "production"
			if stored_config.has_key? :production
				prod = stored_config[:production]
				host            = prod[:host] if prod.has_key? :host
				adapter         = prod[:adapter] if prod.has_key? :adapter
				database        = prod[:database] if prod.has_key? :database
				max_connections = prod[:max_connections] if prod.has_key? :max_connections
				user            = prod[:user] if prod.has_key? :user
				password        = prod[:password] if prod.has_key? :password
				port            = prod[:port] if prod.has_key? :port
				logger          = prod[:logger] if prod.has_key? :logger
			end
		when "test"
			if stored_config.has_key? :test
				testing = stored_config[:test]
				host            = testing[:host] if testing.has_key? :host
				adapter         = testing[:adapter] if testing.has_key? :adapter
				database        = testing[:database] if testing.has_key? :database
				max_connections = testing[:max_connections] if testing.has_key? :max_connections
				user            = testing[:user] if testing.has_key? :user
				password        = testing[:password] if testing.has_key? :password
				port            = testing[:port] if testing.has_key? :port
				logger          = testing[:logger] if testing.has_key? :logger
			end
		when "development"
			if stored_config.has_key? :development
				develop = stored_config[:development]
				host            = develop[:host] if develop.has_key? :host
				adapter         = develop[:adapter] if develop.has_key? :adapter
				database        = develop[:database] if develop.has_key? :database
				max_connections = develop[:max_connections] if develop.has_key? :max_connections
				user            = develop[:user] if develop.has_key? :user
				password        = develop[:password] if develop.has_key? :password
				port            = develop[:port] if develop.has_key? :port
				logger          = develop[:logger] if develop.has_key? :logger
			end
		end

		app.options[:database_settings] = app.options[:database_settings] ||= {}

		host            = app.options[:database_settings][:host]            ||=  host
		adapter         = app.options[:database_settings][:adapter]         ||=  adapter
		database        = app.options[:database_settings][:database]        ||=  database
		max_connections = app.options[:database_settings][:max_connections] ||=  max_connections
		user            = app.options[:database_settings][:user]            ||=  user
		password        = app.options[:database_settings][:password]        ||=  password
		port            = app.options[:database_settings][:port]            ||=  port
		logger          = app.options[:database_settings][:logger]          ||=  logger

		{ collapsed_config: [host, adapter, database, max_connections], stored_config: stored_config }
	end

	# get a databse url from settings
	def self.database_url_from_settings(settings = {})
		settings
	end

	# gets a hash of settings from a database url.
	def self.settings_from_database_url(database_url = "")
		database_url
	end

end
