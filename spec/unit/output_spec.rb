# frozen_string_literal: true

RSpec.describe TTY::Logger, "outputs" do
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
end
