require_relative "lib/tty/logger/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-logger"
  spec.version       = TTY::Logger::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = %q{Readable, structured and beautiful terminal logging}
  spec.description   = %q{Readable, structured and beautiful terminal logging}
  spec.homepage      = "https://ttytoolkit.org"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/tty-logger/issues"
  spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/tty-logger/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/tty-logger"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/tty-logger"

  spec.files         = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "pastel", "~> 0.8"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
