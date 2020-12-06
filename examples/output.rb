# frozen_string_literal: true

require_relative "../lib/tty/logger"

file = File.open("errors.log", "a")

TTY::Logger.configure do |config|
  config.metadata = [:all]
  config.handlers = [:stream]
  config.output = file
end

logger = TTY::Logger.new(fields: { app: "myapp", env: "prod" })

logger.error("Failed to deploy")

file.close
