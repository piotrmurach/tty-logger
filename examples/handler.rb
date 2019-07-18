require_relative "../lib/tty/logger"

class MyHandler
  def initialize(options = {})
    @name = options[:name]
  end

  def call(event)
    puts "(#{@name}) #{event.metadata[:name]} #{event.message}"
  end
end

TTY::Logger.configure do |config|
  config.handlers = [[MyHandler, {name: :hello}]]
end

logger = TTY::Logger.new

logger.info("Custom logging")
