# frozen_string_literal: true

require_relative "lib/van/version"

Gem::Specification.new do |spec|
  spec.name = "van"
  spec.version = Van::VERSION
  spec.authors = ["karloscarweber"]
  spec.email = ["me@kow.fm"]

  spec.summary = "Sequel gem Wrapper for camping apps."
  spec.description = "Van is a wrapper for the Sequel gem for use in Camping apps. Includes helpers to get things running, performing migrations, generators, and documentation."
  spec.homepage = "https://van.rubycamping.org"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/karloscarweber/van"
  spec.metadata["changelog_uri"] = "https://github.com/karloscarweber/van/changelog"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "sequel", "~> 5.62.0"
  spec.add_dependency "kdl", "~> 1.0.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
