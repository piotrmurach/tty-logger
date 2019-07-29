# frozen_string_literal: true

require "rspec-benchmark"
require "logger"

RSpec.describe TTY::Logger do
  include RSpec::Benchmark::Matchers

  let(:output) { StringIO.new }

  it "performs 3x slower than native logger" do
    native_logger = Logger.new(output)
    logger = described_class.new(output: output)

    expect {
      logger.info("Deployment done!")
    }.to perform_slower_than {
      native_logger.info("Deployment done!")
    }.at_least(3).times
  end
end
