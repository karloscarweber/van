# frozen_string_literal: true
source "https://rubygems.org"
# Specify your gem's dependencies in van.gemspec
gemspec
gem "rake", "~> 13.0"
gem "sequel", "~> 5.62.0"
# gem "camping", "~> 3.0.0" # Camping maybe shouldn't be a dependency of van.
gem 'kdl'


group :test do
	gem 'minitest', '~> 5.16.3'
	gem 'minitest-reporters'
	gem 'rack-test'
	gem 'camping', git: 'https://github.com/karloscarweber/camping', branch: 'camping-3' # This is gonna be changed to the release version of camping when it is released.
	gem 'tilt'
	gem 'puma'
	gem 'sqlite3'
end
