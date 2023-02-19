# van_defaults.rb
# test if it gets the defaults running how we expect.
# Part of these tests are if we parse the KDL config document correctly.

require 'test_helper'

begin

	ENV["environment"] = "development"

	$:.unshift File.dirname(__FILE__) + '../../'

	# Camping.goes :Defaults

	module Defaults
		# pack(Van)
	end

	class Defaults::Test < ReloadingTestCase
		BASE = File.expand_path('../apps/defaults', __FILE__)
		def file; BASE + '.rb' end

		def setup
			set_name :Defaults
			move_to_tmp()
			write_rakefile()
			reloader.reload!

			super
		end

		def teardown
			leave_tmp()
			super
		end

		def test_it_loads_defaults
			app.pack Van
			assert app.options.has_key?(:database_settings), "We don't even have the database settings. #{app}"
			dbs = app.options[:database_settings]
			assert dbs[:adapter] == 'sqlite3', "Database adapter is wrong. #{ dbs[:adapter]}"
			assert dbs[:database] == 'db/camping.db', "Default database name is wrong. #{ dbs[:database]}"
			assert dbs[:host] == 'localhost', "Default host is wrong. #{ dbs[:host]}"
			assert dbs[:max_connections] == 5, "Default database max_connections is wrong. #{ dbs[:max_connections]}"
		end

		def test_it_loads_kdl_defaults
			write_good_kdl(Dir.pwd)
			@kdl = Van.parse_kdl("db/config.kdl")
			# First test if we're even getting kdl back.
			assert_equal 'KDL::Document', @kdl.class.to_s, "The returned object is nil, or at least it's not of class KDL::Document, Actual: #{@kdl.class.to_s}"
		end

		def test_it_loads_good_kdl
			unset_options()
			write_kdl_different_kdl()
			app.pack Van

			assert app.options.has_key?(:database_settings), "We don't even have the database settings. #{app}"
			dbs = app.options[:database_settings]
			assert dbs[:adapter] == 'postgres', "Database adapter is wrong. #{ dbs[:adapter]}"
			unset_options()
		end

		# def test_database_url_widget_thing_works
		# 	database = { user: "kow", database: "homebase", port: "5352",  }
		# 	assert_equal Van.database_url_from_settings(database), { user: "kow", database: "homebase", }
		# end

		def unset_options
			app.options[:database_settings] = {}
		end
	end
rescue => error
	warn "Skipping Defaults tests: "
	warn "  Error: #{error}"
end
