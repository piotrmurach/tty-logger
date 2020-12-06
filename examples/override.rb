# frozen_string_literal: true

require_relative "../lib/tty/logger"

logger = TTY::Logger.new

logger.success("Default success")
logger.error("Default error")

puts

new_style = TTY::Logger.new do |config|
  config.handlers = [
    [:console, {
      styles: {
        success: {
          symbol: "+",
          label: "Ohh yes"
        },
        error: {
          symbol: "!",
          label: "Dooh",
          levelpad: 3
        }
      }
    }]
  ]
end

new_style.success("Custom success")
new_style.error("Custom error")
