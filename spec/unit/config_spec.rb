# frozen_string_literal: true

RSpec.describe TTY::Logger::Config do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "defaults :max_bytes to 8192" do
    config = described_class.new
    expect(config.max_bytes).to eq(8192)
  end

  it "defaults :max_depth to 3" do
    config = described_class.new
    expect(config.max_depth).to eq(3)
  end

  it "defaults :level to :info" do
    config = described_class.new
    expect(config.level).to eq(:info)
  end

  it "sets :max_bytes" do
    config = described_class.new
    config.max_bytes = 2**8
    expect(config.max_bytes).to eq(256)
  end

  it "defaults metadata to empty array" do
    config = described_class.new
    expect(config.metadata).to eq([])
  end

  it "defaults handlers to console" do
    config = described_class.new
    expect(config.handlers).to eq([:console])
  end

  it "defaults formatter to text" do
    config = described_class.new
    expect(config.formatter).to eq(:text)
  end

  it "defaults date format to [%F]" do
    config = described_class.new
    expect(config.date_format).to eq("[%F]")
  end

  it "serializes data into hash" do
    config = described_class.new
    expect(config.to_h).to eq({
      date_format: "[%F]",
      formatter: :text,
      handlers: [:console],
      level: :info,
      max_bytes: 8192,
      max_depth: 3,
      metadata: [],
      time_format: "[%T.%3N]"
    })
  end

  it "yields configuration instance" do
    config = double(:config)
    allow(TTY::Logger).to receive(:config).and_return(config)
    expect { |block|
      TTY::Logger.configure(&block)
    }.to yield_with_args(config)
  end

  it "configures output size" do
    logger = TTY::Logger.new(output: output) do |config|
      config.max_bytes = 2**4
      config.level = :debug
    end

    logger.debug("Deploying", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[36m#{styles[:debug][:symbol]}\e[0m ",
      "\e[36mdebug\e[0m   ",
      "Deploying                 ",
      "\e[36mapp\e[0m=myapp ...\n"
    ].join)
  end

  it "configures maximum depth of structured data" do
    logger = TTY::Logger.new(output: output) do |config|
      config.max_depth = 1
      config.level = :debug
    end

    logger.debug("Deploying", app: "myapp", env: { name: "prod" })

    expect(output.string).to eq([
      "\e[36m#{styles[:debug][:symbol]}\e[0m ",
      "\e[36mdebug\e[0m   ",
      "Deploying                 ",
      "\e[36mapp\e[0m=myapp \e[36menv\e[0m={...}\n"
    ].join)
  end
end
