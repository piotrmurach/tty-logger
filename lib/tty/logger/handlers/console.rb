# frozen_string_literal: true

require "pastel"

module TTY
  class Logger
    module Handlers
      class Console
        STYLES = {
          debug: {
            label: "debug",
            symbol: "•",
            color: :cyan,
            levelpad: 2
          },
          info: {
            label: "info",
            symbol: "ℹ",
            color: :green,
            levelpad: 3
          },
          warn: {
            label: "warning",
            symbol: "⚠",
            color: :yellow,
            levelpad: 0
          },
          error: {
            label: "error",
            symbol: "⨯",
            color: :red,
            levelpad: 2
          },
          fatal: {
            label: "fatal",
            symbol: "!",
            color: :red,
            levelpad: 2
          }
        }

        attr_reader :output

        attr_reader :config

        def initialize(output: $stderr, formatter: nil, config: nil)
          @output = output
          @formatter = formatter
          @config = config
          @mutex = Mutex.new
          @pastel = Pastel.new
        end

        # Handle log event output in format
        #
        # @param [Event] event
        #   the current event logged
        #
        # @api public
        def call(event)
          @mutex.lock

          style = STYLES[event.metadata[:name]]
          color = configure_color(style)

          fmt = []
          fmt << color.(style[:symbol])
          fmt << color.(style[:label]) + (" " * style[:levelpad])
          fmt << "%-25s" % event.message.join(" ")
          unless event.fields.empty?
            fmt << @formatter.dump(event.fields, max_bytes: config.max_bytes).
                    gsub(/(\S+)(?=\=)/, color.("\\1"))
          end

          output.puts fmt.join(" ")
        ensure
          @mutex.unlock
        end

        def configure_color(style)
          color = style.fetch(:color) { :cyan }
          @pastel.send(color).detach
        end
      end # Console
    end # Handlers
  end # Logger
end # TTY
