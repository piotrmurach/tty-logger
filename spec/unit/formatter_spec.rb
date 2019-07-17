# frozen_string_literal: true

RSpec.describe TTY::Logger, "formatter" do 
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "changes default formatter to JSON via class name" do
    logger = TTY::Logger.new(output: output) do |config|
      config.formatter = TTY::Logger::Formatters::JSON
    end

    logger.info("Logging", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                   ",
      "{\"app\":\"myapp\",\"env\":\"prod\"}\n"].join)
  end

  it "changes default formatter for only one handler" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:console,
                         [:console, {formatter: TTY::Logger::Formatters::JSON}]]
    end

    logger.info("Logging", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                   ",
      "\e[32mapp\e[0m=myapp \e[32menv\e[0m=prod\n",
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                   ",
      "{\"app\":\"myapp\",\"env\":\"prod\"}\n"].join)
  end
end
