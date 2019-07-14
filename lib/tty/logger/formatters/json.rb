# frozen_string_literal: true

require "json"

module TTY
  class Logger
    module Formatters
      class JSON
        def dump(obj, options = {})
          ::JSON.generate(obj)
        end
      end # JSON
    end # Formatters
  end # Logger
end # TTY
