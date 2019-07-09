require_relative "../lib/tty/logger"

TTY::Logger.configure do |config|
  config.max_bytes = 2**5
end

logger = TTY::Logger.new(level: :debug, fields: {app: "myapp", env: "prod"})

logger.with(path: "/var/www/example.com").info("Deploying", "code")

puts "Levels:"

logger.debug("Debugging deployment")
logger.info("Info about the deploy")
logger.warn("Lack of resources")
logger.error("Failed to deploy")
logger.fatal("Terribly failed to deploy")
