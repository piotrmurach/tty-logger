require_relative "../lib/tty/logger"

logger = TTY::Logger.new(level: :debug, fields: {app: "myapp", env: "prod"})

logger.with(path: "/var/www/example.com").info("Deploying", "code")

puts "Level loggers:"

logger.debug("Debugging")
logger.info("For the information about some very long process")
logger.warn("Are you sure?")
logger.error("Failed to deploy")
logger.fatal("Terribley failed to deploy")
