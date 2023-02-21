# lib/van/migrations.rb
# Collect code related to migrations, creating them, adding them to rake, etc...

begin
	require 'sequel'
	Sequel.extension :migration
rescue LoadError => e
	raise "Sequel Migration Extension could not be loaded (is it installed?): #{e.message}"
end

module Van

	class Migration
		@timestamp = Van::Migrations.version_name
		@up_statments = []
		@down_statements = []

		def initialize(args)
			@arguments = args.clone
			pipe(args)
		end

		# generates and returns the stream
		def stream
			@stream = ""
			@stream << STREAM_START
			@stream << UP_START

			@up_statments.each do |s|
				@stream << s
			end

			@stream << "	" << ENDING
			@stream << "	" << DOWN_START


			@down_statements.each do |s|
				@stream << s
			end
			@stream << "	" << ENDING
			@stream << ENDING

		end

		# Use TABS to indent. for accessibility reasons
		STREAM_START "Sequel.migration do\n"
		UP_START "	up do\n"
		DOWN_START "	down do\n"
		ENDING = "end\n"


		protected

		# We're working from this documentation to write the generator: https://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html

		# determines what to do next.
		def pipe(args)
			case args.shift
			when "add" # add a column to a table
				add(args)
			when "remove" # removes a column from a table
				remove(args)
			when "create" # creates a table
				create(args)
			when "join" # creates a join table
				create(args)
			when "drop" # drops a table
				drop(args)
			else
				puts "help messages"
			end

		end

		def add(args)
			# what type of add?
			argument = args.shift
			case argument
			when "index" # adds an index
				puts "Add and Index stuff"
			else
				puts "Standard add a column thing"

			end
		end

		def remove(args)
		end

		def create(args)
		end

		def drop(args)
		end

		# parse a column string


	end


	module Migrations
		class << self

			def generate_migration(args)
				migration = Migration.new(args)
				# @@pipepointer = 0
				puts args

				# case args[0]
				# when "version", "-v"
				# 	puts Van.version
				# else
				# 	puts "help messages"
				# end
				# @@migration, @@pipepointer = nil
			end

			# migration generation utility classes
			# returns a file name in the format: timestamp_migrationname.rb
			#
			def version_name()
				# stamp = Time.now.strftime("%Y%m%d%H%M")
				stamp = Time.now.strftime("%Y%jT%H%MZ")
			end

			# Configurator TBD
			# def configure(options = {})
				# Deprecations
				# configuration
			# end

			def load_tasks(options = {})
				# configure(options) # TBD
			end

		end

	end
end
