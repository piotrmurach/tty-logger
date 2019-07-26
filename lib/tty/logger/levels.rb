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
        debug: DEBUG_LEVEL,
        info: INFO_LEVEL,
        warn: WARN_LEVEL,
        error: ERROR_LEVEL,
        fatal: FATAL_LEVEL
      }

      def level_names
        LEVEL_NAMES.keys
      end

      # @api private
      def level_to_number(level)
        LEVEL_NAMES[level.to_s.downcase.to_sym] ||
          raise(ArgumentError, "Invalid level #{level.inspect}")
      end

      # @api private
      def number_to_level(number)
        LEVEL_NAMES.key(number)
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
