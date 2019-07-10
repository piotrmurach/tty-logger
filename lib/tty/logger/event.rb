# frozen_string_literal: true

module TTY
  class Logger
    class Event
      attr_reader :message

      attr_reader :fields

      attr_reader :metadata

      def initialize(message, fields, metadata)
        @message = message
        @fields = fields
        @metadata = metadata
      end
    end # Event
  end # Logger
end # TTY
