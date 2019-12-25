# frozen_string_literal: true

module TTY
  class Logger
    class DataFilter
      FILTERED = "[FILTERED]"
      DOT = "."

      attr_reader :filters, :mask

      # Create a data filter instance with filters.
      #
      # @example
      #  TTY::Logger::DataFilter.new(%w[foo], mask: "<SECRET>")
      #
      # @param [String] mask
      #   the mask to replace object with. Defaults to `"[FILTERED]"`
      #
      # @api private
      def initialize(filters = [], mask: FILTERED)
        @mask = mask
        @filters = filters
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
        filters.any? do |filter|
          case filter
          when Proc
            filter.(composite_key.dup)
          when Regexp
            if filter.to_s.include?(DOT)
              !!filter.match(composite_key.join(DOT))
            else
              !!filter.match(key.to_s)
            end
          else
            exp = Regexp.escape(filter)
            reg = Regexp.new("^#{exp}$")
            if exp.include?(DOT)
              !!reg.match(composite_key.join(DOT))
            else
              !!reg.match(key.to_s)
            end
          end
        end
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
