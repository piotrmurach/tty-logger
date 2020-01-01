# frozen_string_literal: true

require "rspec-benchmark"
require "logger"

RSpec.describe TTY::Logger do
  include RSpec::Benchmark::Matchers

  let(:output) { StringIO.new }

  it "performs at most 4.5x slower than native logger" do
    native_logger = Logger.new(output)
    logger = described_class.new(output: output)

    expect {
      logger.info("Deployment done!")
    }.to perform_slower_than {
      native_logger.info("Deployment done!")
    }.at_most(4.5).times
  end
end
