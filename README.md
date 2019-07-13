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
* Formats and truncates messages to avoid clogging logging output
* Includes metadata information: time, location, scope

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-logger


## Contents

* [1. Usage](#1-usage)
* [2. Synopsis](#2-synopsis)
  * [2.1 Levels](#21-levels)
  * [2.2 Structured Data](#22-structured-data)
  * [2.3 Configuration](#23-configuration)
  * [2.4 Handlers](#24-handlers)

## 1. Usage

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

## 2. Synopsis

### 2.1 Levels

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

### 2.2 Structured data

To add global data available for all logger calls:

```ruby
logger = TTY::Logger.new(fields: {app: "myapp", env: "prod"})

logger.info("Deploying...")
# =>
# ℹ info Deploying...    app=myapp env=prod
```

To only add data for a single log event:

```ruby
logger = TTY::Logger.new

logger.with(app: "myapp", env: "prod").info("Deplying...")
# => Deploying... app=myapp env=prod
```

### 2.3 Configuration

All the configuration options can be changed globally via `configure` or per logger instance via object initialization.

* `:handlers` - the handlers used to log messages. Defaults to `[:console]`. See [Handlers](#24-handlers) for more details.
* `:level` - the logging level. Any message logged below this level will be simply ignored. Each handler may have it's own default level. Defaults to `:info`
* `:max_bytes` - the maximum message size to be logged in bytes. Defaults to `8192` bytes. The truncated message will have `...` at the end.
* `:metadata` - the meta info to display before the message, can be `:date`, `:time`. Defaults to `[]`

For example, to configure `:max_bytes`, `:level` and `:metadata` for all logger instances do:

```ruby
TTY::Logger.configure do |config|
  config.max_bytes = 2**10
  config.level = :error
  config.metadata = [:time, :date]
end
```

Or if you wish to setup configuration per logger instance do:

```ruby
my_config = TTY::Logger::Config.new
my_config.max_bytes = 2**10

logger = TTY::Logger.new(config: my_config)
```

### 2.4 Handlers

The available handlers by default are:

* `Handlers::Console` - log messages to the console, enabled by default

#### 2.4.1 Console handler

#### 2.4.2 Custom handler

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
