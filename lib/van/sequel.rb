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

				if adapter == 'postgres'

				end

				if adapter == 'mysql'

				end

			end
		end
	end

	# Add the ClassMethods when we're included.
	def self.included(mod)
		$DBSTUFF = <<-RUBY
		attr_accessor :DB
			def DB
				self.db
			end
			def DB=(d)
				self.db = d
			end
		RUBY
		mod.instance_eval $DBSTUFF
		mod.extend(ClassMethods)
	end

	def self.setup(app, *a, &block)
		# Puts the Base Class into your apps' Models module.
		app::Models.module_eval $SEQUEL_TO_BASE

		# Expects an array, hence parallel assignment. Should probably always get one too.
		self.squash_settings(app) => {
			collapsed_config:
			# stored_config:
		}
		host, adapter, database, max_connections = collapsed_config

		# store the database settings into the app.
		app.set(:database_settings, {
			:adapter => adapter,
			:database => database,
			:host => host,
			:max_connections => max_connections
		})

		# how to Establish the database connection.
		# Because we're doing all of this in the setup method
		# The connection will take place when this gear is packed.
		# app::Models::Base.establish_connection(
		#   :adapter => adapter,
		#   :database => database,
		#   :host => host,
		#   :max_connections => max_connections
		# )
		# Interesting side effect. If we pack this gear into more than one app,
		# Then each app will have a database connection to manage.
	end

	def self.load_sqlite3_stuff
		begin
			require 'sqlite3'
		rescue LoadError => e
			raise "sqlite3 could not be loaded (is it installed?): #{e.message}"
		end
	end

end



