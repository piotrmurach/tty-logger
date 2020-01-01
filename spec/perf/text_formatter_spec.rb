# frozen_string_literal: true

require "rspec-benchmark"

RSpec.describe TTY::Logger::Formatters::Text do
  include RSpec::Benchmark::Matchers

  it "formats large hashes(2048 keys) at most 3.5x slower than the native JSON" do
    large_data = Hash[Array.new(2048) { |i| [i + 1, "hey"] }]
    formatter = described_class.new

    expect {
      formatter.dump(large_data)
    }.to perform_slower_than {
      ::JSON.dump(large_data)
    }.at_most(3.5).times
  end

  it "formats large values at most 8x slower than the native JSON" do
    large_data = { "foo" => "b#{'a'*2048}" }
    formatter = described_class.new

    expect {
      formatter.dump(large_data)
    }.to perform_slower_than {
      ::JSON.dump(large_data)
    }.at_most(8).times
  end
end
