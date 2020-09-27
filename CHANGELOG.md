# Change log

## [v0.5.0] - 2020-09-27

### Added
* Add :message_format option to customize how messages are displayed in the console
  by Josh Greenwood (@JoshTGreenwood)

### Fixed
* Fix to select event name from valid log types or current level
  by Ryan Schlesinger (@ryansch)
* Fix duplicate filters attribute definition in TTY::Logger::Config

## [v0.4.0] - 2020-07-29

### Added
* Allow editing logger configuration at runtime ([#10](https://github.com/piotrmurach/tty-logger/pull/10))
* Support for the `<<` streaming operator ([#9](https://github.com/piotrmurach/tty-logger/pull/9)))

### Changed
* Change gemspec to update pastel version and restrict only to minor version

### Fixed
* Fix to filter sensitive information from exceptions

## [v0.3.0] - 2020-01-01

### Added
* Add ability to filter sensitive information out of structured data

### Changed
* Remove the test and task files from the gemspec

### Fixed
* Fix console handler highlighting of nested hash keys

## [v0.2.0] - 2019-09-30

### Added
* Add ability to add structured data inside logging block
* Add ability to filter sensitive data
* Add ability to define custom log types
* Add ability to temporarily log at different level
* Add performance tests

### Changed
* Change to dynamically define log types

## [v0.1.0] - 2019-07-21

* Initial implementation and release

[v0.5.0]: https://github.com/piotrmurach/tty-logger/compare/v0.4.0..v0.5.0
[v0.4.0]: https://github.com/piotrmurach/tty-logger/compare/v0.3.0..v0.4.0
[v0.3.0]: https://github.com/piotrmurach/tty-logger/compare/v0.2.0..v0.3.0
[v0.2.0]: https://github.com/piotrmurach/tty-logger/compare/v0.1.0..v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-logger/compare/v0.1.0
