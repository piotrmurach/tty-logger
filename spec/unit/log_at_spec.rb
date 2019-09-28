# frozen_string_literal: true

RSpec.describe TTY::Logger, "#log_at" do
  let(:output) { StringIO.new }

  it "logs temporarily at noisy level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:stream]
    end

    logger.debug("not logged")

    logger.log_at :debug do
      logger.debug("logged")
    end

    logger.debug("not logged")

    expect(output.string).to eq("level=debug message=logged\n")
  end

  it "logs temporarily at quiet level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:stream]
    end

    logger.log_at TTY::Logger::ERROR_LEVEL do
      logger.debug("not logged")
      logger.error("logged")
    end

    expect(output.string).to eq("level=error message=logged\n")
  end
end
