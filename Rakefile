# frozen_string_literal: true
require "bundler/gem_tasks"

require 'rake'
require 'rake/task'
require 'rake/clean'
require 'rake/testtask'
require 'tempfile'
require 'open3'
# require 'van'
# require 'van/version'

module Rake
TESTOPTIONS = {}
end

TESTOPTIONS = {}
Rake::TESTOPTIONS[:verbose] = false

task :default => :test
task :test => 'test:all'

namespace 'test' do

	# all Tests
	Rake::TestTask.new(:all) do |t, args|
		t.libs << 'test'
		t.libs.push 'lib'
		t.test_files = FileList['test/van_*.rb']
		# t.test_files = FileList['test/van_simple.rb']
	end

end
