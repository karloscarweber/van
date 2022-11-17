# frozen_string_literal: true
# lib/van/settings
# load and parse settings.

begin
	require 'kdl'
rescue LoadError => e
	raise "kdl could not be loaded (is it installed?): #{e.message}"
end
