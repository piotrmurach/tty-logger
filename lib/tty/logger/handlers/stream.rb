# frozen_string_literal: true

module TTY
  class Logger
    module Handlers
      class Stream
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
      end # Stream
    end # Handlers
  end # Logger
end # TTY
