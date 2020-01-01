# frozen_string_literal: true

RSpec.describe TTY::Logger, "formatter" do 
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "changes default formatter to JSON as class name" do
    logger = TTY::Logger.new(output: output) do |config|
      config.formatter = TTY::Logger::Formatters::JSON
    end

    logger.info("Logging", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                   ",
      "{\"\e[32mapp\e[0m\":\"myapp\",\"\e[32menv\e[0m\":\"prod\"}\n"].join)
  end

  it "changes default formatter to JSON as name" do
    logger = TTY::Logger.new(output: output) do |config|
      config.formatter = :json
    end

    logger.info("Logging", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                   ",
      "{\"\e[32mapp\e[0m\":\"myapp\",\"\e[32menv\e[0m\":\"prod\"}\n"].join)
  end

  it "changes default formatter for only one handler" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:console,
                         [:console, {formatter: :JSON}]]
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
      "{\"\e[32mapp\e[0m\":\"myapp\",\"\e[32menv\e[0m\":\"prod\"}\n"].join)
  end

  it "formats nested data colors correctly" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:console, [:console, {formatter: :JSON}]]
    end

    logger.info("Logging", "[params]": {"{app}" => "myapp", env: "prod"})

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                   ",
      "\"\e[32m[params]\e[0m\"={\"\e[32m{app}\e[0m\"=myapp \e[32menv\e[0m=prod}\n",
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                   ",
      "{\"\e[32m[params]\e[0m\":",
      "{\"\e[32m{app}\e[0m\":\"myapp\",\"\e[32menv\e[0m\":\"prod\"}}\n"].join)
  end

  it "fails to recognize formatter object type" do
    expect {
      TTY::Logger.new(output: output) do |config|
        config.formatter = true
      end
    }.to raise_error(TTY::Logger::Error, "Unrecognized formatter name 'true'")
  end

  it "fails to recognize formatter name" do

    expect {
      TTY::Logger.new(output: output) do |config|
        config.formatter = :unknown
      end
    }.to raise_error(TTY::Logger::Error, "Unrecognized formatter name ':unknown'")
  end
end
