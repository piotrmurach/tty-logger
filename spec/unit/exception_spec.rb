# frozen_string_literal: true

RSpec.describe TTY::Logger, "exception logging" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "handles exception type message when console" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end
    error = nil

    begin
      raise ArgumentError, "Wrong data"
    rescue => ex
      error = ex
      logger.fatal("Error:", error)
    end

    expect(output.string).to eq([
      "\e[31m#{styles[:fatal][:symbol]}\e[0m ",
      "\e[31mfatal\e[0m   ",
      "Error: Wrong data         \n",
      "#{error.backtrace.map {|bktrace| bktrace.to_s.insert(0, " " * 4) }.join("\n")}\n"
    ].join)
  end

  it "handles exception type message when stream" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:stream]
    end

    error = nil

    begin
      raise ArgumentError, "Wrong data"
    rescue => ex
      error = ex
      logger.fatal("Error:", error)
    end

    expect(output.string).to eq([
      "level=fatal message=\"Error: Wrong data\" backtrace=\"",
      "#{error.backtrace.map {|bktrace| bktrace }.join(",")}\"\n"
    ].join)
  end
end
