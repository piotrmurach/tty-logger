# frozen_string_literal: true

require_relative "logger/config"
require_relative "logger/event"
require_relative "logger/formatters/json"
require_relative "logger/formatters/text"
require_relative "logger/handlers/console"
require_relative "logger/handlers/null"
require_relative "logger/handlers/stream"
require_relative "logger/levels"
require_relative "logger/version"

module TTY
  class Logger
    include Levels

    # Error raised by this logger
    class Error < StandardError; end

    # Logger configuration instance
    #
    # @api public
    def self.config
      @config ||= Config.new
    end

    # Global logger configuration
    #
    # @api public
    def self.configure
      yield config
    end

    # Create a logger instance
    #
    # @example
    #   logger = TTY::Logger.new(output: $stdout)
    #
    # @api public
    def initialize(output: nil, fields: {})
      @fields = fields
      @config = if block_given?
                  conf = Config.new
                  yield(conf)
                  conf
                else
                  self.class.config
                end
      @level = @config.level
      @handlers = @config.handlers
      @output = output || @config.output
      @ready_handlers = []

      @handlers.each do |handler|
        add_handler(handler)
      end
    end

    # Add handler for logging messages
    #
    # @example
    #   add_handler(:console)
    #
    # @api public
    def add_handler(handler)
      h, options = *(handler.is_a?(Array) ? handler : [handler, {}])
      name = coerce_handler(h)
      global_opts = { output: @output, config: @config }
      opts = global_opts.merge(options)
      ready_handler = name.new(opts)
      @ready_handlers << ready_handler
    end

    # Remove log events handler
    #
    # @example
    #   remove_handler(:console)
    #
    # @api public
    def remove_handler(handler)
      @ready_handlers.delete(handler)
    end

    # Coerce handler name into object
    #
    # @example
    #   coerce_handler(:console)
    #   # => TTY::Logger::Handlers::Console
    #
    # @raise [Error] when class cannot be coerced
    #
    # @return [Class]
    #
    # @api private
    def coerce_handler(name)
      case name
      when String, Symbol
        Handlers.const_get(name.capitalize)
      when Class
        name
      else
        raise_handler_error
      end
    rescue NameError
      raise_handler_error
    end

    # Raise error when unknown handler name
    #
    # @api private
    def raise_handler_error
      raise Error, "Handler needs to be a class name or a symbol name"
    end

    # Add structured data
    #
    # @example
    #   logger = TTY::Logger.new
    #   logger.with(app: "myenv", env: "prod").debug("Deplying")
    #
    # @return [TTY::Logger]
    #   a new copy of this logger
    #
    # @api public
    def with(new_fields)
      self.class.new(fields: @fields.merge(new_fields), output: @output)
    end

    # Check current level against another
    #
    # @return [Symbol]
    #
    # @api public
    def log?(level, other_level)
      compare_levels(level, other_level) != :gt
    end

    # Log a message given the severtiy level
    #
    # @example
    #   logger.log("Deployed successfully")
    #
    # @example
    #   logger.log { "Deployed successfully" }
    #
    # @api public
    def log(current_level, *msg, **scoped_fields)
      fields_copy = scoped_fields.dup
      if msg.empty? && block_given?
        msg = []
        Array[yield].flatten(1).each do |el|
          el.is_a?(::Hash) ? fields_copy.merge!(el) : msg << el
        end
      end

      loc = caller_locations(2,1)[0]
      metadata = {
        level: current_level,
        time: Time.now,
        pid: Process.pid,
        name: caller_locations(1,1)[0].label,
        path: loc.path,
        lineno: loc.lineno,
        method: loc.base_label
      }
      event = Event.new(msg, @fields.merge(fields_copy), metadata)

      @ready_handlers.each do |handler|
        level = handler.respond_to?(:level) ? handler.level : @config.level
        handler.(event) if log?(level, current_level)
      end
      self
    end

    # Log a message at :debug level
    #
    # @api public
    def debug(*msg, &block)
      log(:debug, *msg, &block)
    end

    # Log a message at :info level
    #
    # @examples
    #   logger.info "Successfully deployed"
    #   logger.info { "Dynamically generated info" }
    #
    # @api public
    def info(*msg, &block)
      log(:info, *msg, &block)
    end

    # Log a message at :warn level
    #
    # @api public
    def warn(*msg, &block)
      log(:warn, *msg, &block)
    end

    # Log a message at :error level
    #
    # @api public
    def error(*msg, &block)
      log(:error, *msg, &block)
    end

    # Log a message at :fatal level
    #
    # @api public
    def fatal(*msg, &block)
      log(:fatal, *msg, &block)
    end

    # Log a message with a success label
    #
    # @api public
    def success(*msg, &block)
      log(:info, *msg, &block)
    end

    # Log a message with a wait label
    #
    # @api public
    def wait(*msg, &block)
      log(:info, *msg, &block)
    end
  end # Logger
end # TTY
