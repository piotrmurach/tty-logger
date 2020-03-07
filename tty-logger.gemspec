lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tty/logger/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-logger"
  spec.version       = TTY::Logger::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["me@piotrmurach.com"]
  spec.summary       = %q{Readable, structured and beautiful terminal logging}
  spec.description   = %q{Readable, structured and beautiful terminal logging}
  spec.homepage      = "https://piotrmurach.github.io/tty"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/tty-logger/issues"
  spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/tty-logger/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/tty-logger"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/tty-logger"

  spec.files         = Dir["lib/**/*.rb", "tty-logger.gemspec"]
  spec.files        += Dir["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.executables   = []
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "pastel", "~> 0.7.0"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
