# frozen_string_literal: true

require_relative "handlers/console"

module TTY
  class Logger
    class Config
      # The format used for date display
      attr_accessor :date_format

      # The format used for time display
      attr_accessor :time_format

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

      def initialize(**options)
        @max_bytes = options.fetch(:max_bytes) { 2**13 }
        @max_depth = options.fetch(:max_depth) { 3 }
        @level = options.fetch(:level) { :info }
        @metadata = options.fetch(:metadata) { [] }
        @handlers = options.fetch(:handlers) { [:console] }
        @formatter = options.fetch(:formatter) { :text }
        @date_format = options.fetch(:date_format) { "[%F]" }
        @time_format = options.fetch(:time_format) { "[%T.%3N]" }
      end

      # Hash representation of this config
      #
      # @api public
      def to_h
        {
          date_format: date_format,
          formatter: formatter,
          handlers: handlers,
          level: level,
          max_bytes: max_bytes,
          max_depth: max_depth,
          metadata: metadata,
          time_format: time_format
        }
      end
    end # Config
  end # Logger
end # TTY
