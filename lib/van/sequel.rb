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

		# Sets up a database constant with the connection settings
		def establish_connection

			if self.options.has_key? :database
				self.options[:database] => {
					adapter:,
					# user:,
					# password:,
					# host:,
					# port:,
					database:,
					# max_connections:
				}

				begin

					if adapter == 'sqlite3' || adapter == 'sqlite'
						Van.load_sqlite()
						begin
							Van.fill_directories_if_empty(database)
							self.DB = Sequel.sqlite("#{database}")
						rescue Sequel::DatabaseConnectionError => e
							puts "Unable to connect to database: #{e}."
							puts "database: #{database}."
						end
					end

					if adapter == 'postgres'
					end

					if adapter == 'mysql'
					end

				rescue SQLite3::CantOpenException => e
					puts "Database could not be connected: #{e.message}"
					raise "Database could not be connected: #{e.message}"
				end

			end
		end
	end

	# Add the ClassMethods when we're included.
	def self.included(mod)
		$DBSTUFF = <<-RUBY
		attr_accessor :DB
			def DB
				@@db
			end
			def DB=(d)
				@@db = d
			end
			@@db = nil
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
		}
		host, adapter, database, max_connections, user, password, port = collapsed_config

		# store the database settings into the app.
		app.set(:database, {
			:adapter => adapter,
			:database => database,
			:host => host,
			:max_connections => max_connections,
			:user => user,
			:password => password,
			:port => port
		})

		# setup database constant in the app.
		app.establish_connection()
	end

	def self.load_sqlite
		begin
			require 'sqlite3'
		rescue LoadError => e
			raise "sqlite3 could not be loaded (is it installed?): #{e.message}"
		end
	end

	# makes nested directories for a file path if they don't exist.
	def self.fill_directories_if_empty(db_location)
		splitted = db_location.split('/')
		splitted.pop
		root = ""
		splitted.each do |d|
			break if d == ''
			Dir.mkdir(root+d) unless Dir.exist?(root+d)
			root << d << "/"
		end
	end

end
