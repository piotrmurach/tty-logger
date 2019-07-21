# frozen_string_literal: true

RSpec.describe TTY::Logger, "outputs" do
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "outputs to multiple streams of the same handler" do
    stream = StringIO.new

    logger = TTY::Logger.new do |config|
      config.handlers = [[:stream, formatter: :text]]
      config.output = [stream, stream]
    end

    logger.info("logging")

    expect(stream.string).to eq([
      "level=info message=logging\n",
      "level=info message=logging\n"
    ].join)
  end

  it "outputs each handler to a different stream" do
    stream = StringIO.new

    logger = TTY::Logger.new do |config|
      config.handlers = [
        [:console, output: stream],
        [:stream, output: stream]
      ]
    end

    logger.info("logging")

    expect(stream.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m \e[32minfo\e[0m    ",
      "logging                  \n",
      "level=info message=logging\n"
    ].join)
  end
end
