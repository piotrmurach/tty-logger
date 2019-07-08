<div align="center">
  <a href="https://piotrmurach.github.io/tty" target="_blank"><img width="130" src="https://cdn.rawgit.com/piotrmurach/tty/master/images/tty.png" alt="tty logo" /></a>
</div>

# TTY::Logger

[![Gem Version](https://badge.fury.io/rb/tty-logger.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-logger.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/vtrkdk0naknnxoog?svg=true)][appveyor]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-logger/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-logger/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-logger.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/tty
[gem]: http://badge.fury.io/rb/tty-logger
[travis]: http://travis-ci.org/piotrmurach/tty-logger
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-logger
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-logger
[coverage]: https://coveralls.io/github/piotrmurach/tty-logger
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-logger

> A readable, structured and beautiful logging for the terminal

**TTY::Logger** provides independent logging component for [TTY toolkit](https://github.com/piotrmurach/tty).

## Features

* Intuitive console output for an increased readability
* Supports structured data logging

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-logger

## Usage

Create logger:

```ruby
logger = TTY::Logger.new
```

Log information:

```ruby
logger.info "Successfully deployed"
logger.info { "Dynamically generated info" }
```

User different [levels](#levels) to differentiate log events:

```ruby
logger.debug "Deploying..."
logger.info "Deploying..."
logger.warn "Deploying..."
logger.error "Deploying..."
logger.fatal "Deploying..."
```

### Levels

The supported levels, ordered by precedence, are:

* `:debug` - for debug-related messages
* `:info` - for information of any kind
* `:warn` - for warnings
* `:error` - for errors
* `:fatal` - for fatal conditions

So the order is: `:debug` < `:info` < `:warn` < `:error` < `:fatal`

For example, `:info` takes precedence over `:debug`. If your log level is set to `:info`, `:info`, `:warn`, `:error` and `:fatal` will be printed to the console. If your log level is set to `:warn`, only `:warn`, `:error` and `:fatal` will be printed.

You can set level using the following:

```ruby
TTY::Logger.new level: :info
TTY::Logger.new level: "INFO"
TTY::Logger.new level: TTY::Logger::INFO_LEVEL
```

### Structured logging

To add global data available for all logger calls:

```ruby
logger = TTY::Logger.new(fields: {app: "myapp", env: "prod"})

logger.info("Deploying...")
# => Deploying... app=myapp env=prod
```

To only add data for a single log event:

```ruby
logger = TTY::Logger.new

logger.with(app: "myapp", env: "prod").info("Deplying...")
# => Deploying... app=myapp env=prod
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TTY::Logger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/tty-logger/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2019 Piotr Murach. See LICENSE for further details.
