# frozen_string_literal: true

RSpec.describe TTY::Logger::Handlers::Null, "null handler" do
  let(:output) { StringIO.new }

  it "doesn't log with a null handler" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:null]
    end

    logger.info("Logging")

    expect(output.string).to eq("")
  end
end
