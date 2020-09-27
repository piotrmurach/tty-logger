# frozen_string_literal: true

require "json"

module TTY
  class Logger
    module Formatters
      # Format data suitable for data exchange
      class JSON
        ELLIPSIS = "..."

        # Dump data into a JSON formatted string
        #
        # @param [Hash] obj
        #   the object to serialize as JSON
        #
        # @return [String]
        #
        # @api public
        def dump(obj, max_bytes: 2**12, max_depth: 3)
          bytesize = 0

          hash = obj.each_with_object({}) do |(k, v), acc|
            str = (k.to_json + v.to_json)
            items = acc.keys.size - 1

            if bytesize + str.bytesize + items + ELLIPSIS.bytesize > max_bytes
              acc[k] = ELLIPSIS
              break acc
            else
              bytesize += str.bytesize
              acc[k] = dump_val(v, max_depth)
            end
          end
          ::JSON.generate(hash)
        end

        private

        def dump_val(val, depth)
          case val
          when Hash then enc_obj(val, depth - 1)
          when Array then enc_arr(val, depth - 1)
          else
            val
          end
        end

        def enc_obj(obj, depth)
          return ELLIPSIS if depth.zero?

          obj.each_with_object({}) { |(k, v), acc| acc[k] = dump_val(v, depth) }
        end

        def enc_arr(obj, depth)
          return ELLIPSIS if depth.zero?

          obj.each_with_object([]) { |v, acc| acc << dump_val(v, depth) }
        end
      end # JSON
    end # Formatters
  end # Logger
end # TTY
