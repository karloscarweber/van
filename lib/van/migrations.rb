# lib/van/migrations.rb
# Collect code related to migrations, creating them, adding them to rake, etc...

begin
	require 'sequel'
	Sequel.extension :migration
rescue LoadError => e
	raise "Sequel Migration Extension could not be loaded (is it installed?): #{e.message}"
end

					# StandaloneMigrations::Tasks.load_tasks
					# Van::Tasks.load_tasks

module Van
	class Tasks
		class << self

			# Configurator TBD
			# def configure(options = {})
				# Deprecations
				# configuration
			# end

			def load_tasks(options = {})
				# configure(options) # TBD
			end

		end


		class << self
			def load_tasks(options = {})

				MinimalRailtieConfig.load_tasks
				%w(
					connection
					environment
					db/new_migration
				).each do
					|task| load "standalone_migrations/tasks/#{task}.rake"
				end
				load "active_record/railties/databases.rake"
			end
		end


	end
end
