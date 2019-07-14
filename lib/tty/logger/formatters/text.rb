# frozen_string_literal: true

module TTY
  class Logger
    module Formatters
      # Format data suitable for text reading
      class Text
        SPACE = " "
        LPAREN = "("
        RPAREN = ")"
        LBRACE = "{"
        RBRACE = "}"
        LBRACKET = "["
        RBRACKET = "]"
        ELLIPSIS = "..."
        LITERAL_TRUE = "true"
        LITERAL_FALSE = "false"
        LITERAL_NIL = "nil"
        SINGLE_QUOTE_REGEX = /'/.freeze
        ESCAPE_DOUBLE_QUOTE = "\""
        ESCAPE_STR_REGEX = /[ ="|{}()\[\]^$+*?.-]/.freeze
        NUM_REGEX = /^-?\d*(?:\.\d+)?\d+$/.freeze

        # Dump data in a single formatted line
        #
        # @param [Hash] obj
        #   the object to serialize as text
        #
        # @return [String]
        #
        # @api public
        def dump(obj, max_bytes: 2**12, max_depth: 3)
          bytesize = 0

          line = obj.reduce([]) do |acc, (k, v)|
            str = "#{dump_key(k)}=#{dump_val(v, max_depth)}"
            items = acc.size - 1

            if bytesize + str.bytesize + items > max_bytes
              if bytesize + items + (acc[-1].bytesize - ELLIPSIS.bytesize) > max_bytes
                acc.pop
              end
              acc << ELLIPSIS
              break acc
            else
              bytesize += str.bytesize
              acc << str
            end
            acc
          end
          line.join(SPACE)
        end

        private

        def dump_key(key)
          key = key.to_s
          case key
          when SINGLE_QUOTE_REGEX
            key.inspect
          when ESCAPE_STR_REGEX
            ESCAPE_DOUBLE_QUOTE + key.inspect[1..-2] + ESCAPE_DOUBLE_QUOTE
          else
            key
          end
        end

        def dump_val(val, depth)
          case val
          when Hash           then enc_obj(val, depth - 1)
          when Array          then enc_arr(val, depth - 1)
          when String, Symbol then enc_str(val)
          when Complex        then enc_cpx(val)
          when Float          then enc_float(val)
          when Numeric        then enc_num(val)
          when Time           then enc_time(val)
          when TrueClass      then LITERAL_TRUE
          when FalseClass     then LITERAL_FALSE
          when NilClass       then LITERAL_NIL
          else
            val
          end
        end

        def enc_obj(obj, depth)
          return LBRACE + ELLIPSIS + RBRACE if depth.zero?

          LBRACE +
            obj.map { |k, v| "#{dump_key(k)}=#{dump_val(v, depth)}" }.join(SPACE) +
            RBRACE
        end

        def enc_arr(array, depth)
          return LBRACKET + ELLIPSIS + RBRACKET if depth.zero?

          LBRACKET + array.map { |v| dump_val(v, depth) }.join(SPACE) + RBRACKET
        end

        def enc_cpx(val)
          LPAREN + val.to_s + RPAREN
        end

        def enc_float(val)
          ("%f" % val).sub(/0*?$/, "")
        end

        def enc_num(val)
          val
        end

        def enc_str(str)
          str = str.to_s
          case str
          when SINGLE_QUOTE_REGEX
            str.inspect
          when ESCAPE_STR_REGEX, LITERAL_TRUE, LITERAL_FALSE, LITERAL_NIL, NUM_REGEX
            ESCAPE_DOUBLE_QUOTE + str.inspect[1..-2] + ESCAPE_DOUBLE_QUOTE
          else
            str
          end
        end

        def enc_time(time)
          time.strftime("%FT%T%:z")
        end
      end # Text
    end # Formatters
  end # Logger
end # TTY
