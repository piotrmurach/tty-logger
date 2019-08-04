require_relative "../lib/tty/logger"

logger = TTY::Logger.new do |config|
  config.types = {thanks: {level: :info}, done: {level: :info}}
  config.handlers = [
    [:console, {
      styles: {
        thanks: {
          symbol: "❤️ ",
          label: "thanks",
          color: :magenta,
          levelpad: 0
        },
        done: {
          symbol: "!!",
          label: "done",
          color: :green,
          levelpad: 2
        }
      }
    }]
  ]
end

logger.info("This is info!")
logger.thanks("Great work!")
logger.done("Work done!")
