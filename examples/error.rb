require_relative "../lib/tty/logger"

logger = TTY::Logger.new(fields: {app: "myapp", env: "prod"}) do |config|
end

begin
  raise ArgumentError, "Wrong data"
rescue => ex
  error = ex
  logger.fatal("Error:", error)
end
