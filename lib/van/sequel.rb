# frozen_string_literal: true
# lib/van/sequel.rb
# load sequel and add some helper methods for running sequel.

begin
		require 'sequel'
rescue LoadError => e
		raise "Sequel could not be loaded (is it installed?): #{e.message}"
end

$SEQUEL_TO_BASE = <<-RUBY
	Base = Sequel::Model unless const_defined? :Base
RUBY

module Van
	class Error < StandardError; end

	module ClassMethods
		def establish_connection

			if self.options.has_key? :database_settings
				self.options[:database_settings] => { adapter:, user:, password:, host:, port:, database:, max_connections:}

				if adapter == 'sqlite3'
					self.DB = Sequel.connect(adapter: adapter, user: user, password: password, host: host, port: port,
					database: database, max_connections: max_connections)
				end

			end
		end
	end

	# Add the ClassMethods when we're included.
	def self.included(mod)
		mod.extend(ClassMethods)
	end

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
				# logger: Logger.new('log/db.log')
			}
		}
	end

	def self.setup(app, *a, &block)
		# Puts the Base Class into your apps' Models module.
		app::Models.module_eval $SEQUEL_TO_BASE

		# Expects an array, hence parallel assignment. Should probably always get one too.
		self.squash_settings(app) => {
			collapsed_config:,
			stored_config:
		}
		host, adapter, database, pool = collapsed_config

		# does that generatin action!
		# This is not required, like at all.
		# generate_config_yml(stored_config)

		# store the database settings into the app.
		app.set(:database_settings, {
			:adapter => adapter,
			:database => database,
			:host => host,
			:pool => pool
		})

		# how to Establish the database connection.
		# Because we're doing all of this in the setup method
		# The connection will take place when this gear is packed.
		# app::Models::Base.establish_connection(
		#   :adapter => adapter,
		#   :database => database,
		#   :host => host,
		#   :pool => pool
		# )
		# Interesting side effect. If we pack this gear into more than one app,
		# Then each app will have a database connection to manage.
	end

	def self.get_config
		self.db_defaults
	end

	# squash settings basically collapses all the settings that we have into something
	# truly beautiful.
	def self.squash_settings(app)
		defaults = self.db_defaults

		stored_config = self.get_config
		environment = ENV['environment'] ||= "development"

		# The defaults are all for local hosting.
		host      = defaults[:default][:host]
		adapter   = defaults[:default][:adapter]
		database  = defaults[:default][:database]
		pool      = defaults[:default][:max_connections]

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
			end
		when "test"
			if stored_config.has_key? :test
				testing = stored_config[:test]
				host            = testing[:host] if testing.has_key? :host
				adapter         = testing[:adapter] if testing.has_key? :adapter
				database        = testing[:database] if testing.has_key? :database
				max_connections = testing[:max_connections] if testing.has_key? :max_connections
			end
		when "development"
			if stored_config.has_key? :development
				develop = stored_config[:development]
				host            = develop[:host] if develop.has_key? :host
				adapter         = develop[:adapter] if develop.has_key? :adapter
				database        = develop[:database] if develop.has_key? :database
				max_connections = develop[:max_connections] if develop.has_key? :max_connections
			end
		end

		# Overwrite any settings with directly added app settings.
		host            = app.options[:host]            ||=  host
		adapter         = app.options[:adapter]         ||=  adapter
		database        = app.options[:database]        ||=  database
		max_connections = app.options[:max_connections] ||=  max_connections

		{ collapsed_config: [host, adapter, database, pool], stored_config: stored_config}
	end

	def self.load_sqlite3_stuff
		begin
			require 'sqlite3'
		rescue LoadError => e
			raise "sqlite3 could not be loaded (is it installed?): #{e.message}"
		end
	end

end



