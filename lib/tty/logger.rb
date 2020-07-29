# frozen_string_literal: true

require_relative "logger/config"
require_relative "logger/data_filter"
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

    LOG_TYPES = {
      debug: { level: :debug },
      info: { level: :info },
      warn: { level: :warn },
      error: { level: :error },
      fatal: { level: :fatal },
      success: { level: :info },
      wait: { level: :info }
    }.freeze

    # Macro to dynamically define log types
    #
    # @api private
    def self.define_level(name, log_level = nil)
      const_level = (LOG_TYPES[name.to_sym] || log_level)[:level]

      loc = caller_locations(0, 1)[0]
      if loc
        file, line = loc.path, loc.lineno + 7
      else
        file, line = __FILE__, __LINE__ + 3
      end
      class_eval(<<-EOL, file, line)
        def #{name}(*msg, &block)
          log(:#{const_level}, *msg, &block)
        end
      EOL
    end

    define_level :debug
    define_level :info
    define_level :warn
    define_level :error
    define_level :fatal
    define_level :success
    define_level :wait

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

    # Instance logger configuration
    #
    # @api public
    def configure
      yield @config
    end

    # Create a logger instance
    #
    # @example
    #   logger = TTY::Logger.new(output: $stdout)
    #
    # @param [IO] output
    #   the output object, can be stream
    #
    # @param [Hash] fields
    #   the data fields for each log message
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
      @data_filter = DataFilter.new(@config.filters.data,
                                    mask: @config.filters.mask)

      @config.types.each do |name, log_level|
        add_type(name, log_level)
      end

      @handlers.each do |handler|
        add_handler(handler)
      end
    end

    # Add new log type
    #
    # @example
    #   add_type(:thanks, {level: :info})
    #
    # @api private
    def add_type(name, log_level)
      if respond_to?(name)
        raise Error, "Already defined log type #{name.inspect}"
      end
      self.class.define_level(name, log_level)
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
      ready_handler = name.new(**opts)
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

    # Copy this logger
    #
    # @example
    #   logger = TTY::Logger.new
    #   child_logger = logger.copy(app: "myenv", env: "prod")
    #   child_logger.info("Deploying")
    #
    # @return [TTY::Logger]
    #   a new copy of this logger
    #
    # @api public
    def copy(new_fields)
      new_config = @config.to_proc.call(Config.new)
      if block_given?
        yield(new_config)
      end
      self.class.new(fields: @fields.merge(new_fields),
                     output: @output, &new_config)
    end

    # Check current level against another
    #
    # @return [Symbol]
    #
    # @api public
    def log?(level, other_level)
      compare_levels(level, other_level) != :gt
    end

    # Logs streaming output.
    #
    # @example
    #   logger << "Example output"
    #
    # @api public
    def write(*msg)
      event = Event.new(filter(*msg))

      @ready_handlers.each do |handler|
        handler.(event)
      end

      self
    end

    alias_method :<<, :write

    # Log a message given the severtiy level
    #
    # @example
    #   logger.log(:info, "Deployed successfully")
    #
    # @example
    #   logger.log(:info) { "Deployed successfully" }
    #
    # @api public
    def log(current_level, *msg)
      scoped_fields = msg.last.is_a?(::Hash) ? msg.pop : {}
      fields_copy = scoped_fields.dup
      if msg.empty? && block_given?
        msg = []
        Array[yield].flatten(1).each do |el|
          el.is_a?(::Hash) ? fields_copy.merge!(el) : msg << el
        end
      end
      top_caller = caller_locations(1, 1)[0]
      loc = caller_locations(2, 1)[0] || top_caller
      label = top_caller.label
      metadata = {
        level: current_level,
        time: Time.now,
        pid: Process.pid,
        name: /<top\s+\(required\)>|<main>|<</ =~ label ? current_level : label,
        path: loc.path,
        lineno: loc.lineno,
        method: loc.base_label
      }
      event = Event.new(filter(*msg),
                        @data_filter.filter(@fields.merge(fields_copy)),
                        metadata)

      @ready_handlers.each do |handler|
        level = handler.respond_to?(:level) ? handler.level : @config.level
        handler.(event) if log?(level, current_level)
      end
      self
    end

    # Change current log level for the duration of the block
    #
    # @example
    #   logger.log_at :debug do
    #     logger.debug("logged")
    #   end
    #
    # @param [String] tmp_level
    #   the temporary log level
    #
    # @api public
    def log_at(tmp_level, &block)
      @ready_handlers.each do |handler|
        handler.log_at(tmp_level, &block)
      end
    end

    # Filter message parts for any sensitive information and
    # replace with placeholder.
    #
    # @param [Array[Object]] objects
    #   the messages to filter
    #
    # @return [Array[String]]
    #   the filtered message
    #
    # @api private
    def filter(*objects)
      objects.map do |obj|
        case obj
        when Exception
          backtrace = Array(obj.backtrace).map { |line| swap_filtered(line) }
          copy_error(obj, swap_filtered(obj.message), backtrace)
        else
          swap_filtered(obj.to_s)
        end
      end
    end

    # Create a new error instance copy
    #
    # @param [Exception] error
    # @param [String] message
    # @param [Array,nil] backtrace
    #
    # @return [Exception]
    #
    # @api private
    def copy_error(error, message, backtrace = nil)
      new_error = error.exception(message)
      new_error.set_backtrace(backtrace)
      new_error
    end

    # Swap string content for filtered content
    #
    # @param [String] obj
    #
    # @api private
    def swap_filtered(obj)
      obj.dup.tap do |obj_copy|
        @config.filters.message.each do |text|
          obj_copy.gsub!(text, @config.filters.mask)
        end
      end
    end
  end # Logger
end # TTY
