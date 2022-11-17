# van_simple.rb
# test if we just have our tests working.

require 'test_helper'

begin

	$:.unshift File.dirname(__FILE__) + '../../'
	ENV["environment"] = "development"

	class TestSimple < TestCase
		include TestCaseReloader
		include CommandLineCommands
		BASE = File.expand_path('../apps/simple', __FILE__)
		def file; BASE + '.rb' end

		def setup
			set_name :Simple
			# move_to_tmp()
			# write_rakefile()

			# the Camping reloader runs from the root for some reason,
			# so when we reload a camping app we need to give it the current
			# test/tmp directory as the location of the database, otherwise
			# we'll create databases in the root of Guidebook which is not
			# what we want.

			# db_loc = Dir.pwd
			# write_good_kdl(db_loc)
			super
			# run_make_db()
		end

		def teardown
			# leave_tmp()
			super
		end

		def test_works
			assert true, "This test worked correctly."
		end
	end

rescue => error
	warn "Skipping Simple tests #{error}"
end
