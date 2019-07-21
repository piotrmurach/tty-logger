# frozen_string_literal: true

RSpec.describe TTY::Logger, "#log" do
  let(:output) { StringIO.new }

  it "logs message with fields in text format" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:stream]
    end

    logger.info("Successfully deployed", app: 'myapp', env: 'prod')

    expect(output.string).to eq([
      "level=info message=\"Successfully deployed\" ",
      "app=myapp env=prod\n"
    ].join)
  end

  it "logs message with all metadata in text format" do
    time_now = Time.new(2019, 7, 21, 14, 04, 35, "+02:00")
    allow(Time).to receive(:now).and_return(time_now)

    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [:stream]
      config.metadata = [:all]
    end

    logger.info("Successfully deployed", app: 'myapp', env: 'prod')

    expect(output.string).to eq([
      "pid=#{Process.pid} ",
      "date=\"2019-07-21\" ",
      "time=\"14:04:35.000\" ",
      "path=\"#{__FILE__}:#{__LINE__ - 6}:in`<top (required)>`\" ",
      "level=info message=\"Successfully deployed\" ",
      "app=myapp env=prod\n"
    ].join)
  end

  it "logs message with fields in JSON format" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:stream, formatter: :json]]
    end

    logger.info("Successfully deployed", app: 'myapp', env: 'prod')

    expect(output.string).to eq([
      "{\"level\":\"info\",\"message\":\"Successfully deployed\",",
      "\"app\":\"myapp\",\"env\":\"prod\"}\n"
    ].join)
  end

  it "logs message with all metadata in json format" do
    time_now = Time.new(2019, 7, 21, 14, 04, 35, "+02:00")
    allow(Time).to receive(:now).and_return(time_now)

    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:stream, formatter: :json]]
      config.metadata = [:all]
    end

    logger.info("Successfully deployed")

    expect(output.string).to eq([
      "{\"pid\":#{Process.pid},",
      "\"date\":\"2019-07-21\",",
      "\"time\":\"14:04:35.000\",",
      "\"path\":\"#{__FILE__}:#{__LINE__ - 6}:in`<top (required)>`\",",
      "\"level\":\"info\",\"message\":\"Successfully deployed\"}\n"
    ].join)
  end
end
