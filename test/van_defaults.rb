# van_defaults.rb
# test if it gets the defaults running how we expect.
# Part of these tests are if we parse the KDL config document correctly.

require 'test_helper'

$:.unshift File.dirname(__FILE__) + '../../'
ENV["environment"] = "development"

begin

	Camping.goes :Defaults
	Defaults.pack(Van)

	class Defaults::Test < TestCase
		include CommandLineCommands

		# leaving these commented out so that it's clear to me where to put setup and teardown stuff when the time arises.
		def setup
			move_to_tmp()

			write_good_kdl
			@kdl = Van.parse_kdl("db/config.kdl")

		end

		def teardown
			leave_tmp()
		end

		def test_it_loads_defaults
			assert app.options.has_key?(:database_settings), "We don't even have the database settings."
			dbs = app.options[:database_settings]
			assert dbs[:adapter] == 'sqlite3', "Database adapter is wrong. #{ dbs[:adapter]}"
			assert dbs[:database] == 'db/camping.db', "Default database name is wrong. #{ dbs[:database]}"
			assert dbs[:host] == 'localhost', "Default host is wrong. #{ dbs[:host]}"
			assert dbs[:pool] == 5, "Default database pool is wrong. #{ dbs[:pool]}"
		end

		def test_it_loads_kdl_defaults
			# First test if we're even getting kdl back.
			assert_equal 'KDL::Document', @kdl.class.to_s, "The returned object is nil, or at least it's not of class KDL::Document, Actual: #{@kdl.class.to_s}"
		end


# 		# Test if Sequel was even loaded
# 		def test_sequel_was_loaded
# 			assert !Sequel.nil?, "Sequel Gem was not loaded."
# 		end
#
# 		# Test if the Van gear was included in the App.
# 		def test_gear_was_packed
# 			assert app.gear.include?(Van), "Here is the packed gear: #{app.gear}. Notice that it's not Van. Like where it at?"
# 		end
#
# 		# Tests that
# 		def test_van_is_ancestor
# 			assert app.ancestors.include?(Van), "Sorry but for some reason Van is not an ancestor: #{app.ancestors}."
# 		end

	end
rescue => error
	warn "Skipping Defaults tests: "
	warn "  Error: #{error}"
end


