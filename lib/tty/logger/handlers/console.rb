# frozen_string_literal: true

module TTY
  class Logger
    module Handlers
      class Console

        attr_reader :output

        def initialize(output: $stderr)
          @output = output
          @mutex = Mutex.new
        end

        def call(*msg, fields)
          @mutex.lock

          fmt = []
          fmt << msg.join(" ")
          fmt << fields unless fields.empty?

          output.puts fmt.join(" ")
        ensure
          @mutex.unlock
        end
      end # Console
    end # Handlers
  end # Logger
end # TTY
