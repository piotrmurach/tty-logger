# frozen_string_literal: true

RSpec.describe TTY::Logger, "#log" do
  let(:output) { StringIO.new }

  it "logs a message" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.info("Successfully", "deployed")

    expect(output.string).to eq("Successfully deployed\n")
  end

  it "doesn't log when lower level" do
    logger = TTY::Logger.new(output: output, level: :warn)

    logger.debug("Successfully deployed")

    expect(output.string).to eq("")
  end
end
