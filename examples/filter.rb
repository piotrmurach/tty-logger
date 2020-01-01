require_relative "../lib/tty/logger"

logger = TTY::Logger.new do |config|
  config.filters.data = [/^foo.*?\.baz/]
end

logger.info("Filtering data", {"foo" => {"bar" => {"baz" => "val"}}, "baz" => ["bar", "val"]})
