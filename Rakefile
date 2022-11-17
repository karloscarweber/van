# frozen_string_literal: true
# require "bundler/gem_tasks"

require 'rake'
require 'rake/task'
require 'rake/clean'
require 'rake/testtask'
require 'tempfile'
require 'open3'
require 'van'
require 'van/version'

# RSpec::Core::RakeTask.new(:spec)

# task default: :spec

task :default => :test
task :default => :test
task :test => 'test:all'

namespace 'test' do
	Rake::TestTask.new('all') do |t|
		t.libs << 'test'
		t.libs.push 'lib'
		t.test_files = FileList['test/van_*.rb']
	end
end
