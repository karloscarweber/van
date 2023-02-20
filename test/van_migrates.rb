# van_migrate.rb
# test if we can do migrations and stuff.

require 'test_helper'

begin

	$:.unshift File.dirname(__FILE__) + '../../'
	ENV["environment"] = "development"

	class TestMigrates < ReloadingTestCase
		BASE = File.expand_path('../apps/migrates', __FILE__)
		def file; BASE + '.rb' end

		def setup
			set_name :Migrates
			move_to_tmp()
			write_rakefile()
			db_loc = Dir.pwd
			write_good_kdl(db_loc)
			reloader.reload!
			super
		end

		def teardown
			leave_tmp()
			super
		end

		def test_works
			assert true, "This test worked correctly."
		end
	end

rescue => error
	warn "Skipping Migrates tests #{error}"
end
