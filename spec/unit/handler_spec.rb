# frozen_string_literal: true

RSpec.describe TTY::Logger, 'handlers' do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "coerces name into handler object" do
    config = TTY::Logger::Config.new
    config.handlers = [:console]

    logger = TTY::Logger.new(config: config, output: output)
    logger.info("Logging")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                  \n"].join)
  end

  it "fails to coerce name into handler object" do
    config = TTY::Logger::Config.new
    config.handlers = [true]

    expect {
      TTY::Logger.new(config: config)
    }.to raise_error(TTY::Logger::Error,
                     "Handler needs to be a class name or a symbol name")
  end
end
