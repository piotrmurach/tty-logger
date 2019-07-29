source "https://rubygems.org"

gemspec

if RUBY_VERSION.split(".")[1].to_i > 0
  gem "rspec-benchmark", git: "https://github.com/piotrmurach/rspec-benchmark"
  # gem "rspec-benchmark", path: "../rspec-benchmark"
end

group :test do
  gem 'benchmark-ips', '~> 2.7.2'
  gem 'simplecov', '~> 0.16.1'
  gem 'coveralls', '~> 0.8.22'
end

group :metrics do
  gem 'yardstick', '~> 0.9.9'
end
