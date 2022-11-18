# simple.rb
# The simple Camping app to test against.
require "camping"
require_relative '../../lib/van.rb'

Camping.goes :ItLoads

module ItLoads
	pack(Van)
end
