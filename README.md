# rgss3

An attempt to maintain https://github.com/CaptainJet/RM-Gosu.

NOT READY TO USE!

At least Ruby 2.3 is required.

Depend on:
* rmagick
* gosu

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rgss3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rgss3

## Usage

```ruby
require 'rgss3'
RGSS3.run do
  # TODO: Add your code here
  # loop { Graphics.update }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taroxd/rgss3.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

