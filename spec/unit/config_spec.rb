# frozen_string_literal: true

RSpec.describe TTY::Logger::Config do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "defaults :max_bytes to 8192" do
    config = described_class.new
    expect(config.max_bytes).to eq(8192)
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

  it "yields configuration instance" do
    config = double(:config)
    allow(TTY::Logger).to receive(:config).and_return(config)
    expect { |block|
      TTY::Logger.configure(&block)
    }.to yield_with_args(config)
  end

  it "configures output size" do
    config = TTY::Logger::Config.new
    config.max_bytes = 2**4
    config.level = :debug

    logger = TTY::Logger.new(output: output, config: config)

    logger.debug("Deploying", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[36m#{styles[:debug][:symbol]}\e[0m ",
      "\e[36mdebug\e[0m   ",
      "Deploying                 ",
      "\e[36mapp\e[0m=myapp ...\n"
    ].join)
  end
end
