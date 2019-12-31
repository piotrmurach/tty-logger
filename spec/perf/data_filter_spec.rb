# frozen_string_literal: true

require "rspec-benchmark"

RSpec.describe TTY::Logger::DataFilter do
  include RSpec::Benchmark::Matchers

  def nested_hash(level)
    return {} if level <= 0
    {"a#{level}" => nested_hash(level - 1) }
  end

  it "filters nested hashes efficiently" do
    data_filter = described_class.new(%w[a1])
    deep_data = nested_hash(20)

    expect {
      data_filter.filter(deep_data)
    }.to perform_slower_than {
      ::JSON.dump(deep_data)
    }.at_most(14).times
  end

  it "filters shallow data with many keys efficiently" do
    keys = []
    large_data = Hash[Array.new(20) { |i|
      keys << "a#{i+1}"
      ["a#{i+1}", "hey"]
    }]
    data_filter = described_class.new(keys)

    expect {
      data_filter.filter(large_data)
    }.to perform_slower_than {
      ::JSON.dump(large_data)
    }.at_most(12).times
  end
end
