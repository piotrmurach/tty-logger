# frozen_string_literal: true

RSpec.describe TTY::Logger, "#log" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "logs a message at debug level" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.debug("Successfully", "deployed")

    expect(output.string).to eq([
      "\e[36m#{styles[:debug][:symbol]}\e[0m ",
      "\e[36mdebug\e[0m   ",
      "Successfully deployed\n"].join)
  end

  it "logs a message at info level" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.info("Successfully", "deployed")

    expect(output.string).to eq([
      "\e[36m#{styles[:info][:symbol]}\e[0m ",
      "\e[36minfo\e[0m    ",
      "Successfully deployed\n"].join)
  end

  it "logs a message at error level" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.error("Failed to", "deploy")

    expect(output.string).to eq([
      "\e[31m#{styles[:error][:symbol]}\e[0m ",
      "\e[31merror\e[0m   ",
      "Failed to deploy\n"].join)
  end

  it "logs a message at fatal level" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.fatal("Failed to", "deploy")

    expect(output.string).to eq([
      "\e[31m#{styles[:fatal][:symbol]}\e[0m ",
      "\e[31mfatal\e[0m   ",
      "Failed to deploy\n"].join)
  end

  it "logs a message in a block" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.info { "Successfully deployed" }

    expect(output.string).to eq([
      "\e[36m#{styles[:info][:symbol]}\e[0m ",
      "\e[36minfo\e[0m    ",
      "Successfully deployed\n"].join)
  end

  it "doesn't log when lower level" do
    logger = TTY::Logger.new(output: output, level: :warn)

    logger.debug("Successfully deployed")

    expect(output.string).to eq("")
  end

  it "logs message with global fields" do
    logger = TTY::Logger.new(output: output, fields: {app: 'myapp', env: 'prod'})

    logger.info("Successfully deployed")

    expect(output.string).to eq([
      "\e[36m#{styles[:info][:symbol]}\e[0m ",
      "\e[36minfo\e[0m    ",
      "Successfully deployed {:app=>\"myapp\", :env=>\"prod\"}\n"].join)
  end

  it "logs message with fields" do
    logger = TTY::Logger.new(output: output)

    logger.with(app: 'myapp', env: 'prod').info("Successfully deployed")

    expect(output.string).to eq([
      "\e[36m#{styles[:info][:symbol]}\e[0m ",
      "\e[36minfo\e[0m    ",
      "Successfully deployed {:app=>\"myapp\", :env=>\"prod\"}\n"].join)
  end
end
