require_relative "../lib/tty/logger"

logger = TTY::Logger.new(level: :debug, fields: {app: "myapp", env: "prod"})

logger.with(path: "/var/www/example.com").info("Deploying", "code")

puts "Level loggers:"

logger.debug("Debugging deployment")
logger.info("For the information about the deploy")
logger.warn("Lack of resources to deploy")
logger.error("Failed to deploy")
logger.fatal("Terribly failed to deploy")
