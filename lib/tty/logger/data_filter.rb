# frozen_string_literal: true

module TTY
  class Logger
    class DataFilter
      FILTERED = "[FILTERED]"
      DOT = "."

      attr_reader :filters, :compiled_filters, :mask

      # Create a data filter instance with filters.
      #
      # @example
      #  TTY::Logger::DataFilter.new(%w[foo], mask: "<SECRET>")
      #
      # @param [String] mask
      #   the mask to replace object with. Defaults to `"[FILTERED]"`
      #
      # @api private
      def initialize(filters = [], mask: nil)
        @mask = mask || FILTERED
        @filters = filters
        @compiled_filters = compile(filters)
      end

      # Filter object for keys matching provided filters.
      #
      # @example
      #   data_filter = TTY::Logger::DataFilter.new(%w[foo])
      #   data_filter.filter({"foo" => "bar"})
      #   # => {"foo" => "[FILTERED]"}
      #
      # @param [Object] obj
      #   the object to filter
      #
      # @api public
      def filter(obj)
        hash = obj.reduce({}) do |acc, (k, v)|
          acc[k] = filter_val(k, v)
          acc
        end
        hash
      end

      private

      def compile(filters)
        compiled = {
          regexps: [],
          nested_regexps: [],
          blocks: [],
        }
        strings = []
        nested_strings = []

        filters.each do |filter|
          case filter
          when Proc
            compiled[:blocks] << filter
          when Regexp
            if filter.to_s.include?(DOT)
              compiled[:nested_regexps] << filter
            else
              compiled[:regexps] << filter
            end
          else
            exp = Regexp.escape(filter)
            if exp.include?(DOT)
              nested_strings << exp
            else
              strings << exp
            end
          end
        end

        if !strings.empty?
          compiled[:regexps] << /^(#{strings.join("|")})$/
        end

        if !nested_strings.empty?
          compiled[:nested_regexps] << /^(#{nested_strings.join("|")})$/
        end

        compiled
      end

      def filter_val(key, val, composite = [])
        return mask if filtered?(key, composite)

        case val
        when Hash then filter_obj(key, val, composite << key)
        when Array then filter_arr(key, val, composite)
        else val
        end
      end

      def filtered?(key, composite)
        composite_key = composite + [key]
        joined_key = composite_key.join(DOT)
        @compiled_filters[:regexps].any? { |reg| !!reg.match(key.to_s) } ||
          @compiled_filters[:nested_regexps].any? { |reg| !!reg.match(joined_key) } ||
          @compiled_filters[:blocks].any? { |block| block.(composite_key.dup) }
      end

      def filter_obj(_key, obj, composite)
        obj.reduce({}) do |acc, (k, v)|
          acc[k] = filter_val(k, v, composite)
          acc
        end
      end

      def filter_arr(key, obj, composite)
        obj.reduce([]) do |acc, v|
          acc << filter_val(key, v, composite)
        end
      end
    end # DataFilter
  end # Logger
end # TTY
