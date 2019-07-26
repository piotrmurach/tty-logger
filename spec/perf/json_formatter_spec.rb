# frozen_string_literal: true

require "rspec-benchmark"

RSpec.describe TTY::Logger::Formatters::JSON do
  include RSpec::Benchmark::Matchers

  it "formats large hashes(2048 keys) 2x faster with the native JSON" do
    large_data = Hash[Array.new(2048) { |i| [i + 1, "hey"] }]
    formatter = described_class.new

    expect {
      ::JSON.dump(large_data)
    }.to perform_faster_than {
      formatter.dump(large_data)
    }.at_least(2).times
  end

  it "formats large values 2x faster with the native JSON" do
    large_data = { "foo" => "b#{'a'*2048}" }
    formatter = described_class.new

    expect {
      ::JSON.dump(large_data)
    }.to perform_faster_than {
      formatter.dump(large_data)
    }.at_least(2).times
  end
end
