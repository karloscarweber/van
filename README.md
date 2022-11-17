# Van

Van is a wrapper for the [Sequel](https://sequel.jeremyevans.net) gem for use in Camping apps. It provides some handy helpers, generators, and documentation.

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/van`. To experiment with that code, run `bin/console` for an interactive prompt.

## ToDo

- [ ] Give Van the option to have a custom logger.
- [ ] Make sure that Van passes along all custom options to whatever environment setup we have.
- [ ] Write the code to get config settings from kdl.
- [ ] Figure out if we actually need to make a new Base Class with Sequel backing it.
- [ ] Migrations?

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add van

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install van

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/karloscarweber/van.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
