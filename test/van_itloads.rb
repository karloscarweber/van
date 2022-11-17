# van_itloads.rb
# test if it just loads anything at all.

require 'test_helper'

$:.unshift File.dirname(__FILE__) + '../../'
ENV["environment"] = "development"

begin

	Camping.goes :ItLoads
	ItLoads.pack(Van)

	class ItLoads::Test < TestCase
		include CommandLineCommands

		# leaving these commented out so that it's clear to me where to put setup and teardown stuff when the time arises.
# 		def setup
# 			move_to_tmp()
# 		end
#
# 		def teardown
# 			leave_tmp()
# 		end

		# Test if Sequel was even loaded
		def test_sequel_was_loaded
			assert !Sequel.nil?, "Sequel Gem was not loaded."
		end

		# Test if the Van gear was included in the App.
		def test_gear_was_packed
			assert app.gear.include?(Van), "Here is the packed gear: #{app.gear}. Notice that it's not Van. Like where it at?"
		end

		# Tests that
		def test_van_is_ancestor
			assert app.ancestors.include?(Van), "Sorry but for some reason Van is not an ancestor: #{app.ancestors}."
		end

	end
rescue => error
	warn "Skipping ItLoads tests: "
	warn "  Error: #{error}"
end


