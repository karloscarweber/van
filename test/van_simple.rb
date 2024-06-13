# van_simple.rb
# test if we just have our tests working.

require 'test_helper'

begin

	$:.unshift File.dirname(__FILE__) + '../../'
	ENV["environment"] = "development"

	class TestSimple < ReloadingTestCase
		BASE = File.expand_path('../apps/simple/simple', __FILE__)
		def file; BASE + '.rb' end

		def setup
			set_name :Simple
			move_to_tmp()
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
	warn "Skipping Simple tests #{error}"
end
