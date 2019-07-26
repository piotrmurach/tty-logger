# frozen_string_literal: true

require "rspec-benchmark"

RSpec.describe TTY::Logger::Formatters::Text do
  include RSpec::Benchmark::Matchers

  it "compares text formatter with the native JSON serializer" do
    large_data = { "foo" => "b#{'a'*2048}" }
    formatter = described_class.new

    expect {
      ::JSON.dump(large_data)
    }.to perform_faster_than {
      formatter.dump(large_data)
    }.at_least(4).times
  end
end
