# frozen_string_literal: true

require "rspec-benchmark"

RSpec.describe TTY::Logger::Formatters::JSON do
  include RSpec::Benchmark::Matchers

  it "compares JSON formatter with the native JSON serializer" do
    large_data = { "foo" => "b#{'a'*2048}" }
    formatter = described_class.new

    expect {
      ::JSON.dump(large_data)
    }.to perform_faster_than {
      formatter.dump(large_data)
    }.at_least(2).times
  end
end
