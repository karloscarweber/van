require 'test_helper'

begin

	$:.unshift File.dirname(__FILE__) + '../../'
	ENV["environment"] = "development"

	class SimpleTest < TestCase

		def the_test_works
			assert true, "This test worked correctly."
		end
	end

rescue => error
	warn "Skipping Simple tests #{error}"
end
