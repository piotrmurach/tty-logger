# frozen_string_literal: true

RSpec.describe TTY::Logger, "filters" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "filters a sensitive data from a message" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters = ["secret", "password"]
    end

    logger.info("Super secret info with password")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Super [FILTERED] info with [FILTERED]\n"].join)
  end

  it "filters a sensitive data from a message with custom placeholder" do
    logger = TTY::Logger.new(output: output) do |config|
      config.filters = { "secret" => "<SECRET>" }
    end

    logger.info("Super secret info")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Super <SECRET> info      \n"].join)
  end
end
