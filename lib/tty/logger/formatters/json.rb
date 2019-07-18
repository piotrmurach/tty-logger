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

          hash = obj.reduce({}) do |acc, (k, v)|
            str = (k.to_json + v.to_json)
            items = acc.keys.size - 1

            if bytesize + str.bytesize + items + ELLIPSIS.bytesize > max_bytes
              acc[k] = ELLIPSIS
              break acc
            else
              bytesize += str.bytesize
              acc[k] = dump_val(v, max_depth)
            end
            acc
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

          obj.reduce({}) { |acc, (k, v)| acc[k] = dump_val(v, depth); acc }
        end

        def enc_arr(obj, depth)
          return ELLIPSIS if depth.zero?

          obj.reduce([]) { |acc, v| acc << dump_val(v, depth); acc }
        end
      end # JSON
    end # Formatters
  end # Logger
end # TTY
