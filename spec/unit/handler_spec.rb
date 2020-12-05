# frozen_string_literal: true

RSpec.describe TTY::Logger, 'handlers' do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "coerces name into handler object" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Logging")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                  \n"].join)
  end

  it "coerces class name into handler object" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[TTY::Logger::Handlers::Console,
                         enable_color: true]]
    end

    logger.info("Logging")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Logging                  \n"].join)
  end

  it "changes default handler styling" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [
        [:console, {
          styles: { info: { symbol: "+", label: "INFO" } },
          enable_color: true
        }]
      ]
    end

    logger.info("Logging")

    expect(output.string).to eq([
      "\e[32m+\e[0m ",
      "\e[32mINFO\e[0m    ",
      "Logging                  \n"].join)
  end

  it "defaults format to 25 space padded message" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Logging")

    expect(output.string).to eq(
      "\e[32m#{styles[:info][:symbol]}" \
      "\e[0m \e[32minfo\e[0m    " \
      "Logging                  \n"
    )
  end

  it "changes default message_format" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, { message_format: "%-10s",
                                      enable_color: true }]]
    end

    logger.info("Logging")

    expect(output.string).to eq(
      "\e[32m#{styles[:info][:symbol]}" \
      "\e[0m \e[32minfo\e[0m    " \
      "Logging   \n"
    )
  end

  it "overflows padding when necessary" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, { message_format: "%-0s",
                                      enable_color: true }]]
    end

    logger.info("Logging")

    expect(output.string).to eq(
      "\e[32m#{styles[:info][:symbol]}" \
      "\e[0m \e[32minfo\e[0m    " \
      "Logging\n"
    )
  end

  it "logs different levels for each handler" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [
        [:console, level: :error, enable_color: true],
        [:console, level: :debug, enable_color: true]
      ]
    end

    logger.info("Info")
    logger.error("Error")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m \e[32minfo\e[0m    Info                     \n",
      "\e[31m#{styles[:error][:symbol]}\e[0m \e[31merror\e[0m   Error                    \n",
      "\e[31m#{styles[:error][:symbol]}\e[0m \e[31merror\e[0m   Error                    \n",
    ].join)
  end

  it "fails to coerce unknown object type into handler object" do
    expect {
      TTY::Logger.new do |config|
        config.handlers = [true]
      end
    }.to raise_error(TTY::Logger::Error,
                     "Handler needs to be a class name or a symbol name")
  end

  it "fails to coerce name into handler object" do
    expect {
      TTY::Logger.new do |config|
        config.handlers = [:unknown]
      end
    }.to raise_error(TTY::Logger::Error,
                     "Handler needs to be a class name or a symbol name")
  end
end
