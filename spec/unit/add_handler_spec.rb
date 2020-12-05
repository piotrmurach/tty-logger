# frozen_string_literal: true

RSpec.describe TTY::Logger, "#add_handler" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "dynamically adds and removes a handler object" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = []
    end

    logger.info("No handler")

    logger.add_handler :console, enable_color: true

    logger.info("Console handler")

    logger.remove_handler :console

    logger.info("Console handler removed")

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
      message_format: "%-5s",
      enable_color: true

    logger.info("Console handler")

    logger.remove_handler TTY::Logger::Handlers::Console

    logger.info("Console handler removed")

    expect(output.string).to eq([
      "\e[33m#{styles[:info][:symbol]}\e[0m ",
      "\e[33minfo\e[0m    ",
      "Console handler\n"].join)
  end

  it "removes all handlers matching given type" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [
        :stream,
        [:console, enable_color: true, message_format: "%s"]
      ]
    end

    logger.info("Stream handler")

    logger.add_handler(:stream)

    logger.info("Stream twice")

    logger.remove_handler(:stream)

    logger.info("No stream")

    expect(output.string).to eq([
      "level=info message=\"Stream handler\"\n",
      "\e[32m#{styles[:info][:symbol]}\e[0m \e[32minfo\e[0m    Stream handler\n",
      "level=info message=\"Stream twice\"\n",
      "\e[32m#{styles[:info][:symbol]}\e[0m \e[32minfo\e[0m    Stream twice\n",
      "level=info message=\"Stream twice\"\n",
      "\e[32m#{styles[:info][:symbol]}\e[0m \e[32minfo\e[0m    No stream\n",
    ].join)
  end
end
