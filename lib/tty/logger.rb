# frozen_string_literal: true

require_relative "logger/config"
require_relative "logger/event"
require_relative "logger/formatters/text"
require_relative "logger/levels"
require_relative "logger/version"
require_relative "logger/handlers/console"

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

    # Logging formatter
    attr_reader :formatter

    # The log handling device
    attr_reader :handler

    # Logging severity level
    attr_reader :level

    # By default output to stderr
    attr_reader :output

    def initialize(output: $stderr, level: nil, handler: Handlers::Console,
                   formatter: Formatters::Text, fields: {}, config: Logger.config)
      @output = output
      @fields = fields
      @level = level || config.level
      @formatter = formatter.new
      @handler = handler.new(output: output, formatter: @formatter, config: config)
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
      self.class.new(fields: @fields.merge(new_fields),
                     output: output, level: level)
    end

    # Check current level against another
    #
    # @return [Symbol]
    #
    # @api public
    def log?(other_level)
      compare_levels(level, other_level) != :gt
    end

    # Log a message given the severtiy level
    #
    # @api public
    def log(current_level, *msg, **scoped_fields)
      return unless log?(current_level)

      if msg.empty? && block_given?
        msg = [yield]
      end
      metadata = {
        level: current_level,
        time: Time.now,
        name: current_level
      }
      event = Event.new(msg, @fields.merge(scoped_fields), metadata)
      @handler.(event)
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
  end # Logger
end # TTY
