# frozen_string_literal: true

RSpec.describe TTY::Logger, "#add_handler" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "dynamically adds and removes a handler object" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = []
    end

    logger.info("No handler")

    logger.add_handler :console

    logger.info("Console handler")

    logger.remove_handler :console

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Console handler          \n"].join)
  end

  it "adds a handler object with config options" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = []
    end

    logger.info("No handler")

    logger.add_handler :console,
      styles: {info: {color: :yellow}},
      message_format: "%-5s"

    logger.info("Console handler")

    logger.remove_handler :console

    expect(output.string).to eq([
      "\e[33m#{styles[:info][:symbol]}\e[0m ",
      "\e[33minfo\e[0m    ",
      "Console handler\n"].join)
  end
end
