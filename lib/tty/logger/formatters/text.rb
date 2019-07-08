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
        LITERAL_TRUE = "true"
        LITERAL_FALSE = "false"
        LITERAL_NULL = "null"
        SINGLE_QUOTE_REGEX = /'/
        ESCAPE_DOUBLE_QUOTE = "\""
        ESCAPE_STR_REGEX = /[ ="|{}()\[\]^$+*?.-]/

        # Dump data in a single formatted line
        #
        # @param [Hash] obj
        #   the object to serialize as text
        #
        # @return [String]
        #
        # @api public
        def dump(obj, max_bytes: 2**12)
          bytesize = 0

          line = obj.reduce([]) do |acc, (k, v)|
            if bytesize > max_bytes
              break acc
            end

            str = "#{dump_key(k)}=#{dump_val(v)}"
            bytesize += str.bytesize
            acc << str
            acc
          end
          line.join(" ")
        end

        private

        def dump_key(key)
          key = key.to_s
          case key
          when SINGLE_QUOTE_REGEX
            key.inspect
          else
            key
          end
        end

        def dump_val(val)
          case val
          when Hash           then enc_obj(val)
          when Array          then enc_arr(val)
          when String, Symbol then enc_str(val)
          when Complex        then enc_cpx(val)
          when Float          then enc_float(val)
          when Numeric        then enc_num(val)
          when Time           then enc_time(val)
          when TrueClass      then LITERAL_TRUE
          when FalseClass     then LITERAL_FALSE
          when NilClass       then LITERAL_NULL
          else
            val
          end
        end

        def enc_obj(obj)
          LBRACE +
            obj.map { |k, v| "#{dump_key(k)}=#{dump_val(v)}" }.join(SPACE) +
            RBRACE
        end

        def enc_arr(array)
          LBRACKET + array.map { |v| dump_val(v) }.join(SPACE) + RBRACKET
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
          when ESCAPE_STR_REGEX
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
