# frozen_string_literal: true

RSpec.describe TTY::Logger, "log metadata" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "outputs metadata" do
    time_now = Time.new(2019, 7, 10, 19, 42, 35, "+02:00")
    allow(Time).to receive(:now).and_return(time_now)

    logger = TTY::Logger.new(output: output) do |config|
      config.metadata = [:time, :date, :file]
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Deploying", app: "myapp", env: "prod")

    expected_output = [
      "\e[37m[19:42:35.000]\e[0m ",
      "\e[37m[2019-07-10]\e[0m ",
      "\e[37m[#{__FILE__}:#{__LINE__ - 5}:in`<top (required)>`]\e[0m",
      " #{TTY::Logger::Handlers::Console::ARROW} ",
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Deploying                 ",
      "\e[32mapp\e[0m=myapp \e[32menv\e[0m=prod\n"
    ].join

    expect(output.string).to eq(expected_output)
  end

  it "outputs all metadata when :all key used" do
    time_now = Time.new(2019, 7, 10, 19, 42, 35, "+02:00")
    allow(Time).to receive(:now).and_return(time_now)

    logger = TTY::Logger.new(output: output) do |config|
      config.metadata = [:all]
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Deploying", app: "myapp", env: "prod")

    expected_output = [
      "\e[37m[#{Process.pid}]\e[0m ",
      "\e[37m[2019-07-10]\e[0m ",
      "\e[37m[19:42:35.000]\e[0m ",
      "\e[37m[#{__FILE__}:#{__LINE__ - 6}:in`<top (required)>`]\e[0m",
      " #{TTY::Logger::Handlers::Console::ARROW} ",
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Deploying                 ",
      "\e[32mapp\e[0m=myapp \e[32menv\e[0m=prod\n"
    ].join

    expect(output.string).to eq(expected_output)
  end
end
