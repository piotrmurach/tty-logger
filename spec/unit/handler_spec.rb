# frozen_string_literal: true

RSpec.describe TTY::Logger, 'handlers' do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "coerces name into handler object" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:console]
    end

    logger.info("Logging")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                  \n"].join)
  end

  it "coerces class name into handler object" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [TTY::Logger::Handlers::Console]
    end

    logger.info("Logging")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                  \n"].join)
  end

  it "changes default handler styling" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [
        [:console, {styles: {info: {symbol: "+", label: "INFO"}}}]
      ]
    end

    logger.info("Logging")

    expect(output.string).to eq([
      "\e[32m+\e[0m ",
      "\e[32mINFO\e[0m    ",
      "Logging                  \n"].join)
  end

  it "fails to coerce unknown object type into handler object" do
    expect {
      TTY::Logger.new do |config|
        config.handlers = [true]
      end
    }.to raise_error(TTY::Logger::Error,
                     "Handler needs to be a class name or a symbol name")
  end

  it "fails to coerce name into handler object" do
    expect {
      TTY::Logger.new do |config|
        config.handlers = [:unknown]
      end
    }.to raise_error(TTY::Logger::Error,
                     "Handler needs to be a class name or a symbol name")
  end
end
