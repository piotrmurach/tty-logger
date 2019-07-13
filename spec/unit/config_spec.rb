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

  it "defaults metadata to empty array" do
    config = described_class.new
    expect(config.metadata).to eq([])
  end

  it "defaults handlers to console" do
    config = described_class.new
    expect(config.handlers).to eq([:console])
  end

  it "serializes data into hash" do
    config = described_class.new
    expect(config.to_h).to eq({
      handlers: [:console],
      level: :info,
      max_bytes: 8192,
      metadata: []
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

  it "configures output metadata" do
    time_now = Time.new(2019, 7, 10, 19, 42, 35, "+02:00")
    allow(Time).to receive(:now).and_return(time_now)
    config = TTY::Logger::Config.new
    config.metadata = [:time, :date]

    logger = TTY::Logger.new(output: output, config: config)

    logger.info("Deploying", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[37m[2019-07-10]\e[0m ",
      "\e[37m[19:42:35.000]\e[0m",
      " #{TTY::Logger::Handlers::Console::ARROW} ",
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Deploying                 ",
      "\e[32mapp\e[0m=myapp \e[32menv\e[0m=prod\n"
    ].join)
  end
end
