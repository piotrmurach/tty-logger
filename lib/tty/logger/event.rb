# frozen_string_literal: true

module TTY
  class Logger
    class Event
      attr_reader :message

      attr_reader :fields

      def initialize(message, fields)
        @message = message
        @fields = fields
      end
    end # Event
  end # Logger
end # TTY
