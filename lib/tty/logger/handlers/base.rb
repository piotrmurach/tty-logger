# frozen_string_literal: true

module TTY
  class Logger
    module Handlers
      module Base
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

        # Metadata for the log event
        #
        # @return [Array[Symbol]]
        #
        # @api private
        def metadata
          if config.metadata.include?(:all)
            [:pid, :date, :time, :file]
          else
            config.metadata
          end
        end

        # Format path from event metadata
        #
        # @return [String]
        #
        # @api private
        def format_filepath(event)
          "%s:%d:in`%s`" % [event.metadata[:path], event.metadata[:lineno],
                            event.metadata[:method]]
        end
      end # Base
    end # Handlers
  end # Logger
end # TTY
