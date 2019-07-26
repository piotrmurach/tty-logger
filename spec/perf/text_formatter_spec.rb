# frozen_string_literal: true

require "rspec-benchmark"

RSpec.describe TTY::Logger::Formatters::Text do
  include RSpec::Benchmark::Matchers

  it "formats large hashes(2048 keys) 1.25x faster with the native JSON" do
    large_data = Hash[Array.new(2048) { |i| [i + 1, "hey"] }]
    formatter = described_class.new

    expect {
      ::JSON.dump(large_data)
    }.to perform_faster_than {
      formatter.dump(large_data)
    }.at_least(1.25).times
  end

  it "formats large values 4x faster with the native JSON" do
    large_data = { "foo" => "b#{'a'*2048}" }
    formatter = described_class.new

    expect {
      ::JSON.dump(large_data)
    }.to perform_faster_than {
      formatter.dump(large_data)
    }.at_least(4).times
  end
end
