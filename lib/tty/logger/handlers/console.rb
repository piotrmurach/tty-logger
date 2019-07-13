# frozen_string_literal: true

require "pastel"

module TTY
  class Logger
    module Handlers
      class Console
        ARROW = "›"

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
          },
          success: {
            label: "success",
            symbol: "✔",
            color: :green,
            levelpad: 0
          },
          wait: {
            label: "waiting",
            symbol: "…",
            color: :cyan,
            levelpad: 0
          }
        }

        attr_reader :output

        attr_reader :config

        def initialize(output: $stderr, formatter: nil, config: nil, styles: {})
          @output = output
          @formatter = formatter
          @config = config
          @styles = styles
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

          style = configure_styles(event)
          color = configure_color(style)

          fmt = []
          if config.metadata.include?(:date)
            fmt << @pastel.white(event.metadata[:time].strftime("[%F]"))
          end
          if config.metadata.include?(:time)
            fmt << @pastel.white(event.metadata[:time].strftime("[%T.%3N]"))
          end
          if config.metadata.include?(:file)
            fmt << @pastel.white(format_filepath(event))
          end
          fmt << ARROW unless config.metadata.empty?
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

        private

        def format_filepath(event)
          "[%s:%d:in`%s`]" % [event.metadata[:path], event.metadata[:lineno],
                              event.metadata[:method]]
        end

        # Merge default styles with custom style overrides
        #
        # @return [Hash[String]]
        #   the style matching log type
        #
        # @api private
        def configure_styles(event)
          style = STYLES[event.metadata[:name].to_sym].dup
          (@styles[event.metadata[:name].to_sym] || {}).each do |k, v|
            style[k] = v
          end
          style
        end

        def configure_color(style)
          color = style.fetch(:color) { :cyan }
          @pastel.send(color).detach
        end
      end # Console
    end # Handlers
  end # Logger
end # TTY
