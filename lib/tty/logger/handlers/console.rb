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

        attr_reader :level

        def initialize(output: $stderr, formatter: nil, config: nil, level: nil,
                       styles: {})
          @output = output
          @formatter = coerce_formatter(formatter || config.formatter).new
          @config = config
          @styles = styles
          @mutex = Mutex.new
          @pastel = Pastel.new
          @level = level || @config.level
        end

        # Coerce formatter name into constant
        #
        # @api private
        def coerce_formatter(name)
          case name
          when String, Symbol
            const_name = if Formatters.const_defined?(name.upcase)
                           name.upcase
                         else
                           name.capitalize
                         end
            Formatters.const_get(const_name)
          when Class
            name
          else
            raise_formatter_error(name)
          end
        rescue NameError
          raise_formatter_error(name)
        end

        # Raise error when unknown formatter name
        #
        # @api private
        def raise_formatter_error(name)
          raise Error, "Unrecognized formatter name '#{name.inspect}'"
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
          metadata.each do |meta|
            case meta
            when :date
              fmt << @pastel.white("[" + event.metadata[:time].
                                   strftime(config.date_format) + "]")
            when :time
              fmt << @pastel.white("[" + event.metadata[:time].
                                   strftime(config.time_format) + "]")
            when :file
              fmt << @pastel.white("[#{format_filepath(event)}]")
            when :pid
              fmt << @pastel.white("[%d]" % event.metadata[:pid])
            else
              raise "Unknown metadata `#{meta}`"
            end
          end
          fmt << ARROW unless config.metadata.empty?
          fmt << color.(style[:symbol])
          fmt << color.(style[:label]) + (" " * style[:levelpad])
          fmt << "%-25s" % event.message.join(" ")
          unless event.fields.empty?
            fmt << @formatter.dump(event.fields, max_bytes: config.max_bytes,
                                   max_depth: config.max_depth).
                                   gsub(/(\S+)(?=\=)/, color.("\\1")).
                                   gsub(/\"([^,]+?)\"(?=:)/, "\"" + color.("\\1") + "\"")
          end

          output.puts fmt.join(" ")
        ensure
          @mutex.unlock
        end

        private

        def metadata
          if config.metadata.include?(:all)
            [:pid, :date, :time, :file]
          else
            config.metadata
          end
        end

        def format_filepath(event)
          "%s:%d:in`%s`" % [event.metadata[:path], event.metadata[:lineno],
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
