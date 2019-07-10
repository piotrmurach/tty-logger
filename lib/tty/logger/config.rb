# frozen_string_literal: true

module TTY
  class Logger
    class Config

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
      end

      def to_h
        {
          level: level,
          max_bytes: max_bytes,
          metadata: metadata
        }
      end
    end # Config
  end # Logger
end # TTY
