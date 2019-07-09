# frozen_string_literal: true

RSpec.describe TTY::Logger::Config do
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
end
