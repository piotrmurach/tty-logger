# frozen_string_literal: true

module TTY
  class Logger
    module Levels
      DEBUG_LEVEL = 0
      INFO_LEVEL  = 1
      WARN_LEVEL  = 2
      ERROR_LEVEL = 3
      FATAL_LEVEL = 4

      LEVEL_NAMES = {
        DEBUG_LEVEL => :debug,
        INFO_LEVEL => :info,
        WARN_LEVEL => :warn,
        ERROR_LEVEL => :error,
        FATAL_LEVEL => :fatal
      }

      def level_names
        [:debug, :info, :warn, :error, :fatal]
      end

      # @api private
      def level_to_number(level)
        case level.to_s.downcase
        when "debug" then DEBUG_LEVEL
        when "info"  then INFO_LEVEL
        when "warn"  then WARN_LEVEL
        when "error" then ERROR_LEVEL
        when "fatal" then FATAL_LEVEL
        else
          raise ArgumentError, "Invalid level #{level.inspect}"
        end
      end

      # @api private
      def number_to_level(level)
        LEVEL_NAMES[level]
      end

      # @api private
      def compare_levels(left, right)
        left = left.is_a?(Integer) ? left : level_to_number(left)
        right = right.is_a?(Integer) ? right : level_to_number(right)

        return :eq if left == right
        left < right ? :lt : :gt
      end
    end # Levels
  end # Logger
end # TTY
