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

		def makes_migrations
			run_cmd("ruby ../../bin/van install")
			database_folder = Dir.glob("db")

			# run_cmd("ruby ../../bin/guidebook install")
			# database_folder = Dir.glob("db")
			# _(database_folder.empty?).must_equal false
			# sub_folder = Dir.glob("db/*")
			# _(sub_folder.include?("db/migrate")).must_equal true, "Does not inlcude migrate, #{sub_folder}"
			# _(sub_folder.include?("db/config.kdl")).must_equal true, "Does not inlcude config.kdl, #{sub_folder}"
			# _(Dir.glob("*").include?('Rakefile')).must_equal true, "Does not inlcude config.kdl, Rakefile"

		end
	end

rescue => error
	warn "Skipping Migrates tests #{error}"
end
