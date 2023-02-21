# lib/van/commands.rb
# Collect Command Line type commands that Van can accept.

begin
	require 'sequel'
rescue LoadError => e
	raise "Sequel Gem could not be loaded (is it installed?): #{e.message}"
end

module VAN

	# This module parses commands then feeds those commands into, like, action places.
	module Commands

		# generate stuff
		def self.generate(args)
			# puts args

			case args[0]
			when "migration", "mig"
				Van::Migrations.generate_migration args.drop(1)
			when "model", "mod"
				# puts "This is a generator"
				generate_model(args.drop(1))
			when "view", "v"

			else
				puts "help messages"
			end


		end

		# generate a migration?
		# def self.generate_migration
		# end

		# generate a model?
		def self.generate_model
		end


# 		# Migration stuff
# 		def self.migrate(*args)
# 		end
#
# 		# migrate up
# 		def self.migrate_up
# 		end
#
# 		# migrate to specific migration
# 		def self.migrate_specific
# 		end

	end
end
