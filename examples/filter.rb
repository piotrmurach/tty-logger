require_relative "../lib/tty/logger"

logger = TTY::Logger.new do |config|
  config.filters.data = [/^foo\.ba/]
end

logger.info("Filtering data", {"foo" => {"bar" => "val"}, "baz" => ["bar", "val"]})
