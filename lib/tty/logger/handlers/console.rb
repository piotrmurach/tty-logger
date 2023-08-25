# frozen_string_literal: true

require "pastel"

require_relative "base"

module TTY
  class Logger
    module Handlers
      class Console
        include Base

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
        }.freeze

        TEXT_REGEXP = /([{}()\[\]])?(["']?)(\S+?)(["']?=)/.freeze
        JSON_REGEXP = /\"([^,]+?)\"(?=:)/.freeze

        COLOR_PATTERNS = {
          text: [TEXT_REGEXP, ->(c) { "\\1\\2" + c.("\\3") + "\\4" }],
          json: [JSON_REGEXP, ->(c) { "\"" + c.("\\1") + "\"" }]
        }.freeze

        # The output stream
        # @api private
        attr_reader :output

        # The configuration options
        # @api private
        attr_reader :config

        # The format for the message
        # @api private
        attr_reader :message_format

        def initialize(output: $stderr, formatter: nil, config: nil, level: nil,
                       styles: {}, enable_color: nil, message_format: "%-25s")
          @output = Array[output].flatten
          @formatter = coerce_formatter(formatter || config.formatter).new
          @formatter_name = @formatter.class.name.split("::").last.downcase
          @color_pattern = COLOR_PATTERNS[@formatter_name.to_sym]
          @config = config
          @styles = styles
          @level = level
          @mutex = Mutex.new
          @pastel = Pastel.new(enabled: enable_color)
          @message_format = message_format
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
          unless style.empty?
            fmt << color.(style[:symbol])
            fmt << color.(style[:label]) + (" " * style[:levelpad])
          end
          fmt << message_format % event.message.join(" ")
          unless event.fields.empty?
            pattern, replacement = *@color_pattern
            fmt << @formatter.dump(event.fields, max_bytes: config.max_bytes,
                                                 max_depth: config.max_depth)
                             .gsub(pattern, replacement.(color))
          end
          unless event.backtrace.empty?
            fmt << "\n" + format_backtrace(event)
          end

          output.each { |out| out.puts fmt.join(" ") }
        ensure
          @mutex.unlock
        end

        # @api private
        def level
          @level || @config.level
        end

        private

        def format_backtrace(event)
          indent = " " * 4
          event.backtrace.map do |bktrace|
            indent + bktrace.to_s
          end.join("\n")
        end

        # Merge default styles with custom style overrides
        #
        # @return [Hash[String]]
        #   the style matching log type
        #
        # @api private
        def configure_styles(event)
          return {} if event.metadata[:name].nil?

          STYLES.fetch(event.metadata[:name].to_sym, {})
                .dup
                .merge!(@styles[event.metadata[:name].to_sym] || {})
        end

        def configure_color(style)
          color = style.fetch(:color) { :cyan }
          @pastel.send(color).detach
        end
      end # Console
    end # Handlers
  end # Logger
end # TTY
