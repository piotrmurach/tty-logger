# frozen_string_literal: true

RSpec.describe do
  it "compares names with equal level" do
    logger = TTY::Logger.new
    expect(logger.compare_levels(:info, :info)).to eq(:eq)
  end

  it "compares names with equal level" do
    logger = TTY::Logger.new
    expect(logger.compare_levels("INFO", "INFO")).to eq(:eq)
  end

  it "compares numbers with equal level" do
    logger = TTY::Logger.new
    expect(logger.compare_levels(TTY::Logger::INFO_LEVEL, TTY::Logger::INFO_LEVEL)).to eq(:eq)
  end

  it "compares names with lower level" do
    logger = TTY::Logger.new
    expect(logger.compare_levels(:debug, :warn)).to eq(:lt)
  end

  it "compares numbers with lower level" do
    logger = TTY::Logger.new
    expect(logger.compare_levels(TTY::Logger::DEBUG_LEVEL, TTY::Logger::WARN_LEVEL)).to eq(:lt)
  end

  it "compares names with greater level" do
    logger = TTY::Logger.new
    expect(logger.compare_levels(:error, :info)).to eq(:gt)
  end
end
