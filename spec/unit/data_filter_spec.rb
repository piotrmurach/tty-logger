# frozen_string_literal: true

require_relative "../../lib/tty/logger/data_filter"

RSpec.describe TTY::Logger::DataFilter, "#filter" do
  [
    [{"aaa" => "bbb"}, {"aaa" => "bbb"}, %w[aaaa]],
    [{"aaa" => "bbb"}, {"aaa" => "[FILTERED]"}, %w[aaa]],
    [{"aaa" => "bbb", "bbb" => "aaa"}, {"aaa" => "[FILTERED]", "bbb" => "aaa" }, %w[aaa ccc]],
    [{"aaa" => "bbb", "ccc" => "aaa"}, {"aaa" => "[FILTERED]", "ccc" => "[FILTERED]" }, %w[aaa ccc]],
    [{"bbb" => {"aaa" => "bbb", "bbb" => "aaa"}}, {"bbb" => { "aaa" => "[FILTERED]", "bbb" => "aaa" } }, %w[aaa]],
    [{"aaa" => {"aaa" => "bbb", "bbb" => "aaa"}}, {"aaa" => "[FILTERED]"}, %w[aaa]],
    [{"aaa" => {"bbb" => "aaa", "ccc" => "aaa"}}, {"aaa" => {"bbb" => "[FILTERED]", "ccc" => "[FILTERED]"}}, %w[bbb ccc]],
    [{"bbb" => [{"aaa" => "bbb"}, "ccc"]}, {"bbb" => [{"aaa" => "[FILTERED]"}, "ccc"]}, %w[aaa]],
    [{"bbb" => [{"ccc" => {"aaa" => "bbb"}}]}, {"bbb" => [{"ccc" => {"aaa" => "[FILTERED]"}}]}, %w[aaa]],
    [{"bbb" => [{"ccc" => {"aaa" => "bbb"}}]}, {"bbb" => [{"ccc" => {"aaa" => "[FILTERED]"}}]}, %w[bbb.ccc.aaa]],
    [{"aaa" => {"bbb" => "ccc", "ddd" => "eee"}}, {"aaa" => {"bbb" => "ccc", "ddd" => "[FILTERED]"}}, %w[aaa.ddd]],
    [{"aaa" => {"bbb" => "ccc"}, "ddd" => {"bbb" => "ccc"}}, {"aaa" => {"bbb" => "[FILTERED]"}, "ddd" => {"bbb" => "ccc"}}, %w[aaa.bbb]],
    [{"aaa" => {"bbb" => "ccc", "ddd" => "eee"}}, {"aaa" => {"bbb" => "[FILTERED]", "ddd" => "[FILTERED]"}}, [/^[bd]/]],
    [{"aaa" => {"bbb" => "ccc", "ddd" => "eee"}}, {"aaa" => {"bbb" => "[FILTERED]", "ddd" => "eee"}}, [/aaa\.b/]],
    [{"aaa" => "bbb", "ccc" => "aaa"}, {"aaa" => "[FILTERED]", "ccc" => "aaa" }, [-> (ck) { ck.include?("aaa")}]]
  ].each do |before_filter, after_filter, filters|
    it "filters #{before_filter.inspect} to #{after_filter.inspect} for keys #{filters.inspect}" do
      data_filter = TTY::Logger::DataFilter.new(filters)

      expect(data_filter.filter(before_filter)).to eq(after_filter)
    end
  end

  it "changes values with a custom mask" do
    data_filter = TTY::Logger::DataFilter.new(%w[aaa], mask: "<SECRET>")

    expect(data_filter.filter({"aaa" => "bbb"})).to eq({"aaa" => "<SECRET>"})
  end
end
