# frozen_string_literal: true

module TTY
  class Logger
    class Event
      attr_reader :message

      attr_reader :fields

      attr_reader :metadata

      attr_reader :backtrace

      def initialize(message, fields, metadata)
        @message = message
        @fields = fields
        @metadata = metadata
        @backtrace = []

        evaluate_message
      end

      private

      # Extract backtrace information if message contains exception
      #
      # @api private
      def evaluate_message
        @message.each do |msg|
          case msg
          when Exception
            @backtrace = msg.backtrace
          else
            msg
          end
        end
      end
    end # Event
  end # Logger
end # TTY
