# frozen_string_literal: true

RSpec.describe TTY::Logger, "#log" do
  let(:output) { StringIO.new }

  it "logs a message at info level" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.info("Successfully", "deployed")

    expect(output.string).to eq("Successfully deployed\n")
  end

  it "logs a message in a block" do
    logger = TTY::Logger.new(output: output, level: :debug)

    logger.info { "Successfully deployed" }

    expect(output.string).to eq("Successfully deployed\n")
  end

  it "doesn't log when lower level" do
    logger = TTY::Logger.new(output: output, level: :warn)

    logger.debug("Successfully deployed")

    expect(output.string).to eq("")
  end

  it "logs message with global fields" do
    logger = TTY::Logger.new(output: output, fields: {app: 'myapp', env: 'prod'})

    logger.info("Successfully deployed")

    expect(output.string).to eq("Successfully deployed {:app=>\"myapp\", :env=>\"prod\"}\n")
  end

  it "logs message with fields" do
    logger = TTY::Logger.new(output: output)

    logger.with(app: 'myapp', env: 'prod').info("Successfully deployed")

    expect(output.string).to eq("Successfully deployed {:app=>\"myapp\", :env=>\"prod\"}\n")
  end
end
