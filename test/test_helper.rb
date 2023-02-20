$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/../' # I think this will let us see db folder

# test_helper.rb
begin
	require 'rubygems'
rescue LoadError
end

require 'camping'
require 'camping/reloader'
require 'minitest/autorun'
require 'minitest'
require 'minitest/spec'
require 'rack/test'
require "minitest/reporters"
require_relative '../lib/van.rb'
require 'fileutils'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

$VERBOSE = nil

# Useful functions from guidebook,
# Used to set up the environment a bit for a test
module CommandLineCommands

	def move_to_tmp
		@original_dir = Dir.pwd
		Dir.chdir "test"
		Dir.mkdir("tmp") unless Dir.exist?("tmp")
		Dir.chdir "tmp"
	end

	def leave_tmp
		Dir.chdir @original_dir
		`rm -rf test/tmp` if File.exist?('test/tmp')
	end

	def leave_shadow_db_dir
		`rm -rf db` if File.exist?('db')
	end

	def reset_tmp
		leave_tmp()
		move_to_tmp()
	end

	# write file
	def write(file, content)
		raise "cannot write nil" unless file
		file = tmp_file(file)
		folder = File.dirname(file)
		`mkdir -p #{folder}` unless File.exist?(folder)
		File.open(file, 'w') { |f| f.write content }
	end

	# read file
	def read(file)
		File.read(tmp_file(file))
	end

	# tmp_file, gets the temp file
	def tmp_file(file)
		# "test/tmp/#{file}"
		"#{file}"
	end

	# runs a command on the command line, in the test directory
	# def run_cmd(cmd)
	#   result = `cd test/tmp && #{cmd} 2>&1`
	#   raise result unless $?.success?
	#   result
	# end

	def schema
		ENV['SCHEMA'] || "db/schema.rb"
	end

	# writes a rakefile
	def write_rakefile(config=nil)
			write 'Rakefile', <<-TXT
$LOAD_PATH.unshift '#{File.expand_path('../../'+'lib')}'
begin
	require "cairn"
	StandaloneMigrations::Tasks.load_tasks
rescue LoadError => e
	puts "gem install cairn to get db:migrate:* tasks! (Error: \#{e})"
end
TXT
	end

	def create_db
		run_cmd 'rake db:create'
	end

	def drop_db
		run_cmd 'rake db:drop'
	end

	def make_migration(name, options={})
		task_name = options[:task_name] || 'db:new_migration'
		migration = run("rake #{task_name} name=#{name}").match(%r{db/migrate/\d+.*.rb})[0]
		content = read(migration)
		content.sub!(/def down.*?\send/m, "def down;puts 'DOWN-#{name}';end")
		content.sub!(/def up.*?\send/m, "def up;puts 'UP-#{name}';end")
		write(migration, content)
		migration.match(/\d{14}/)[0]
	end

	def make_pages_migration

		begin
			name = "AddPages"
			migration = run_cmd("rake db:new_migration name=#{name}").match(%r{db/migrate/\d+.*.rb})[0]
			content = read(migration)
			content.sub! (/def change\s+end/m), <<-TXT
def down.*? end
def up.*? end
TXT
			content.sub! (/def down.*?\s+end/m), <<-TXT
def down
	drop_table "pages"
end
TXT
			content.sub! (/def up.*?\s+end/m), <<-TXT
def up
	create_table "pages" do |t|
		t.string :title
		t.text :content
		t.timestamps
	end
end
TXT
			write(migration, content)
			migration.match(/\d{14}/)[0]
		rescue => error
			warn "There was a damn error: #{error}"
			warn "Current directory: #{Dir.glob("*")}"
		end
	end

	def run_make_db
		create_db()
		make_pages_migration()
		run_cmd('rake db:migrate')
	end

	# writes a rakefile and a config.yml
	def before_cmd_actions
		StandaloneMigrations::Configurator.instance_variable_set(:@env_config, nil)
		`rm -rf test/tmp` if File.exist?('test/tmp')
		`mkdir test/tmp`
		write_rakefile
		write(schema, '')
		write 'db/config.yml', <<-TXT
development:
	adapter: sqlite3
	database: db/development.sql
test:
	adapter: sqlite3
	database: db/test.sql
production:
	adapter: sqlite3
	database: db/production.sql
TXT
	end

	# runs a command
	def run_cmd(cmd)
		result = `#{cmd} 2>&1`
		raise result unless $?.success?
		result
	end

	def write_good_kdl(db_loc=nil)
		database = 'db/camping.db'
		if db_loc != nil
			database = db_loc + "/" + database
		end

		write 'db/config.kdl', <<-TXT
// config.kdl
database {
	default adapter="sqlite3" database="#{database}" host="localhost" max_connections=5 timeout=5000
	development
	production adapter="postgres" database="kow"
}
TXT
	end

	def write_kdl_different_kdl
		write 'db/config.kdl', <<-KDL
// config.kdl
database {
	default adapter="postgres" database="persplicity" host="198.172.0.1" max_connections=5 timeout=5000
	development
	production adapter="postgres" database="persplicity"
}
KDL
	end

	def write_bad_kdl
			write 'db/bad.kdl', <<-TXT
// bad.kdl
database
	default adapter="sqlite3" database="db/camping.db" host="localhost" max_connections=5 timeout=5000
	development
	production adapter="postgres" database="kow"
}
TXT
	end

end

# default TestCase Class for your tests.
class TestCase < MiniTest::Test
	include Rack::Test::Methods

	def self.inherited(mod)
		mod.app = Object.const_get(mod.to_s[/\w+/])
		super
	end

	class << self
		attr_accessor :app
	end

	def body() last_response.body end
	def app()  self.class.app     end

	def assert_reverse
		begin
			yield
		rescue Exception
		else
			assert false, "Block didn't fail"
		end
	end

	def assert_body(str)
		case str
		when Regexp
			assert_match(str, last_response.body.strip)
		else
			assert_equal(str.to_s, last_response.body.strip)
		end
	end

	def assert_status(code)
		assert_equal(code, last_response.status)
	end

	# def test_silly; end

end

# A test case reloader for reloading Camping apps.
# Used to freshly start up and spin down apps for the tests.
#
# To use, make sure to include TestCaseReloader in your TestCase class
# and to add a method that returns the file name for the reloader.:
#   def file; BASE + '.rb' end
# Additionally you'll need to inherit from  MiniTest::Test instead of TestCase
module TestCaseReloader
	def reloader
		@reloader ||= Camping::Reloader.new(file) do |app|
	end

	end

	def set_name(const)
		@app_name ||= const.to_sym
	end

	def app_name
		@app_name ||= :Default
	end

	def setup
		super
		reloader.reload!
		assert Object.const_defined?(app_name), "Reloader didn't load app: #{app_name}."
	end

	def teardown
		super
		assert Object.const_defined?(app_name), "Test removed app: #{app_name}."
		reloader.remove_apps
		assert !Object.const_defined?(app_name), "Reloader didn't remove app: #{app_name}."
	end
end

class TestCase
	include CommandLineCommands
end

class ReloadingTestCase < TestCase
	include TestCaseReloader
	def file; BASE + '.rb' end

	# You'll need to rename this to the app that you're reloading.
	BASE = File.expand_path('../apps/default', __FILE__)
end

# TENT! a fake Camping App
class Tent
	def options
		{host: nil, adapter: nil, database: nil, max_connections: nil}
	end
end
