# frozen_string_literal: true

require_relative "handlers/console"

module TTY
  class Logger
    class Config

      # The handlers used to display logging info. Defaults to [:console]
      attr_accessor :handlers

      # The level to log messages at. Default to :info
      attr_accessor :level

      # The maximum message size to be logged in bytes. Defaults to 8192
      attr_accessor :max_bytes

      # The meta info to display, can be :date, :time. Defaults to []
      attr_accessor :metadata

      def initialize(**options)
        @max_bytes = options.fetch(:max_bytes) { 2**13 }
        @level = options.fetch(:level) { :info }
        @metadata = options.fetch(:metadata) { [] }
        @handlers = options.fetch(:handlers) { [TTY::Logger::Handlers::Console] }
      end

      # Hash representation of this config
      #
      # @api public
      def to_h
        {
          handlers: handlers,
          level: level,
          max_bytes: max_bytes,
          metadata: metadata,
        }
      end
    end # Config
  end # Logger
end # TTY
