# frozen_string_literal: true

require_relative "base"

module TTY
  class Logger
    module Handlers
      class Stream
        include Base

        attr_reader :output

        attr_reader :config

        attr_reader :level

        def initialize(output: $stderr, formatter: nil, config: nil, level: nil)
          @mutex = Mutex.new
          @output = output
          @formatter = coerce_formatter(formatter || config.formatter).new
          @config = config
          @level = level || @config.level
        end

        # @api public
        def call(event)
          @mutex.lock

          data = {}
          metadata.each do |meta|
            case meta
            when :date
              data["date"] = event.metadata[:time].strftime(config.date_format)
            when :time
              data["time"] = event.metadata[:time].strftime(config.time_format)
            when :file
              data["path"] = format_filepath(event)
            when :pid
              data["pid"] = event.metadata[:pid]
            else
              raise "Unknown metadata `#{meta}`"
            end
          end
          data["level"] = event.metadata[:level]
          data["message"] = event.message.join(' ')
          unless event.fields.empty?
            data.merge!(event.fields)
          end

          output.puts @formatter.dump(data)
        ensure
          @mutex.unlock
        end
      end # Stream
    end # Handlers
  end # Logger
end # TTY
