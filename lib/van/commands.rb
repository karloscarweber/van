# lib/van/commands.rb
# Collect Command Line type commands that Van can accept.

begin
	require 'sequel'
rescue LoadError => e
	raise "Sequel could not be loaded (is it installed?): #{e.message}"
end
