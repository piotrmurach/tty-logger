# frozen_string_literal: true

module TTY
  class Logger
    module Handlers
      class Null
        def initialize(*)
        end

        def call(*)
          # noop
        end
      end # Null
    end # Handlers
  end # Logger
end # TTY
