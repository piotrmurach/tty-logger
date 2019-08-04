# frozen_string_literal: true

require_relative "handlers/console"

module TTY
  class Logger
    class Config
      # The format used for date display
      attr_accessor :date_format

      # The format used for time display
      attr_accessor :time_format

      # The storage of placholders to filter sensitive data out from the logs. Defaults to {}
      attr_accessor :filters

      # The format used for displaying structured data
      attr_accessor :formatter

      # The handlers used to display logging info. Defaults to [:console]
      attr_accessor :handlers

      # The level to log messages at. Default to :info
      attr_accessor :level

      # The maximum message size to be logged in bytes. Defaults to 8192
      attr_accessor :max_bytes

      # The maximum depth for formattin array and hash objects. Defaults to 3
      attr_accessor :max_depth

      # The meta info to display, can be :date, :time, :file, :pid. Defaults to []
      attr_accessor :metadata

      # The output for the log messages. Defaults to `stderr`
      attr_accessor :output

      # The new custom log types. Defaults to `{}`
      attr_accessor :types

      # Create a configuration instance
      #
      # @api private
      def initialize(**options)
        @max_bytes = options.fetch(:max_bytes) { 2**13 }
        @max_depth = options.fetch(:max_depth) { 3 }
        @level = options.fetch(:level) { :info }
        @metadata = options.fetch(:metadata) { [] }
        @filters  = options.fetch(:filters) { {} }
        @handlers = options.fetch(:handlers) { [:console] }
        @formatter = options.fetch(:formatter) { :text }
        @date_format = options.fetch(:date_format) { "%F" }
        @time_format = options.fetch(:time_format) { "%T.%3N" }
        @output = options.fetch(:output) { $stderr }
        @types = options.fetch(:types) { {} }
      end

      # Hash representation of this config
      #
      # @return [Hash[Symbol]]
      #
      # @api public
      def to_h
        {
          date_format: date_format,
          filters: filters,
          formatter: formatter,
          handlers: handlers,
          level: level,
          max_bytes: max_bytes,
          max_depth: max_depth,
          metadata: metadata,
          output: output,
          time_format: time_format,
          types: types
        }
      end
    end # Config
  end # Logger
end # TTY
