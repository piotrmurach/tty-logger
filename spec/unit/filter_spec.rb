# frozen_string_literal: true

RSpec.describe TTY::Logger, "filters" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "filters a sensitive data from a message" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters.message = ["secret", "password"]
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Super secret info with password")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Super [FILTERED] info with [FILTERED]\n"].join)
  end

  it "filters a sensitive data from a message with custom placeholder" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters.message = %w[secret]
      config.filters.mask = "<SECRET>"
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Super secret info")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Super <SECRET> info      \n"].join)
  end

  it "filters sensitive information from structured data matching keys" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters.data = %w[password]
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Secret password",
                {password: "Secret123", email: "secret@example.com"})

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Secret password           ",
      "\e[32mpassword\e[0m=\"[FILTERED]\" ",
      "\e[32memail\e[0m=\"secret@example.com\"\n",
    ].join)
  end

  it "filters sensitive information from structured data matching composite key" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters.data = %w[params.password]
      config.filters.mask = "<SECRET>"
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Secret password", params: {password: "Secret123",
                                            email: "secret@example.com"})

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Secret password           ",
      "\e[32mparams\e[0m={\e[32mpassword\e[0m=<SECRET> ",
      "\e[32memail\e[0m=\"secret@example.com\"}\n",
    ].join)
  end

  it "filters sensitive data from an error message with backtrace" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters.message = ["secret"]
      config.handlers = [[:console, enable_color: true]]
    end

    arg_error = ArgumentError.new("wrong argument secret")
    arg_error.set_backtrace(["secret error info", "and more secret info"])

    logger.fatal(arg_error)

    expect(output.string).to eq([
      "\e[31m#{styles[:fatal][:symbol]}\e[0m ",
      "\e[31mfatal\e[0m   ",
      "wrong argument [FILTERED] \n",
      "    [FILTERED] error info\n",
      "    and more [FILTERED] info\n"
    ].join)
  end

  it "filters sensitive data from an error message without backtrace" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters.message = ["secret"]
      config.handlers = [[:console, enable_color: true]]
    end

    arg_error = ArgumentError.new("wrong argument secret")

    logger.fatal(arg_error)

    expect(output.string).to eq([
      "\e[31m#{styles[:fatal][:symbol]}\e[0m ",
      "\e[31mfatal\e[0m   ",
      "wrong argument [FILTERED]\n",
    ].join)
  end
end
