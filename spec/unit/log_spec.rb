# frozen_string_literal: true

RSpec.describe TTY::Logger, "#log" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "logs without a method name directly using level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.level = :debug
      config.handlers = [[:console, enable_color: true]]
    end

    logger.log(:debug, "Deploying...")

    expect(output.string).to eq([
      "\e[36m#{styles[:debug][:symbol]}\e[0m ",
      "\e[36mdebug\e[0m   ",
      "Deploying...             \n"
    ].join)
  end

  it "logs when called from another method" do
    logger = TTY::Logger.new(output: output) do |config|
      config.level = :debug
      config.handlers = [[:console, enable_color: true]]
    end

    log_wrapper(logger).call(:debug, "Deploying...")

    expect(output.string).to eq([
      "\e[36m#{styles[:debug][:symbol]}\e[0m ",
      "\e[36mdebug\e[0m   ",
      "Deploying...             \n"
    ].join)
  end

  def log_wrapper(logger)
    ->(level, message) do
      logger.log(level, message)
    end
  end

  it "logs a message at debug level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.level = :debug
      config.handlers = [[:console, enable_color: true]]
    end

    logger.debug("Successfully", "deployed")

    expect(output.string).to eq([
      "\e[36m#{styles[:debug][:symbol]}\e[0m ",
      "\e[36mdebug\e[0m   ",
      "Successfully deployed    \n"].join)
  end

  it "logs a message at info level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Successfully", "deployed")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Successfully deployed    \n"].join)
  end

  it "logs a message at warn level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.warn("Failed to", "deploy")

    expect(output.string).to eq([
      "\e[33m#{styles[:warn][:symbol]}\e[0m ",
      "\e[33mwarning\e[0m ",
      "Failed to deploy         \n"].join)
  end

  it "logs a message at error level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.error("Failed to", "deploy")

    expect(output.string).to eq([
      "\e[31m#{styles[:error][:symbol]}\e[0m ",
      "\e[31merror\e[0m   ",
      "Failed to deploy         \n"].join)
  end

  it "logs a message at fatal level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.fatal("Failed to", "deploy")

    expect(output.string).to eq([
      "\e[31m#{styles[:fatal][:symbol]}\e[0m ",
      "\e[31mfatal\e[0m   ",
      "Failed to deploy         \n"].join)
  end

  it "logs a success message at info level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.success("Deployed", "successfully")

    expect(output.string).to eq([
      "\e[32m#{styles[:success][:symbol]}\e[0m ",
      "\e[32msuccess\e[0m ",
      "Deployed successfully    \n"].join)
  end

  it "logs a wait message at info level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.wait("Waiting for", "deploy")

    expect(output.string).to eq([
      "\e[36m#{styles[:wait][:symbol]}\e[0m ",
      "\e[36mwaiting\e[0m ",
      "Waiting for deploy       \n"].join)
  end

  it "logs a message in a block" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info { "Successfully deployed" }

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Successfully deployed    \n"].join)
  end

  it "logs a message in a block as an array of elements" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info { ["Successfully", "deployed"] }

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Successfully deployed    \n"].join)
  end

  it "logs a message in a block with metadata" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info { ["Successfully", "deployed", {app: "myapp", env: "prod"}] }

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Successfully deployed     ",
      "\e[32mapp\e[0m=myapp \e[32menv\e[0m=prod\n"
    ].join)
  end

  it "doesn't log when lower level" do
    logger = TTY::Logger.new(output: output) do |config|
      config.level = :warn
    end

    logger.debug("Successfully deployed")

    expect(output.string).to eq("")
  end

  it "logs message with global fields" do
    logger = TTY::Logger.new(
      output: output,
      fields: {app: 'myapp', env: 'prod'}) do |config|
        config.handlers = [[:console, enable_color: true]]
      end

    logger.info("Successfully deployed")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Successfully deployed     ",
      "\e[32mapp\e[0m=myapp \e[32menv\e[0m=prod\n"].join)
  end

  it "logs message with scoped fields" do
    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[:console, enable_color: true]]
    end

    logger.info("Successfully deployed", app: 'myapp', env: 'prod')

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Successfully deployed     ",
      "\e[32mapp\e[0m=myapp \e[32menv\e[0m=prod\n"].join)
  end

  it "adds new custom log type" do
    heart = "❤"
    logger = TTY::Logger.new(output: output) do |config|
      config.types = {thanks: {level: :info}}
      config.handlers = [
        [:console, {
          styles: {
            thanks: {
              symbol: heart,
              label: "thanks",
              color: :red,
              levelpad: 1
            }
          },
          enable_color: true
        }]
      ]
    end

    logger.thanks("Great work!", app: "myapp", env: "prod")

    expect(output.string).to eq([
      "\e[31m#{heart}\e[0m ",
      "\e[31mthanks\e[0m  ",
      "Great work!               ",
      "\e[31mapp\e[0m=myapp \e[31menv\e[0m=prod\n"].join)
  end

  it "fails to add already defined log type" do
    expect {
      TTY::Logger.new do |config|
        config.types = {success: {level: :info}}
      end
    }.to raise_error(TTY::Logger::Error, "Already defined log type :success")
  end

  it "logs streaming output" do
    logger = TTY::Logger.new(output: output)

    logger << "Deploying..."

    expect(output.string).to eq([
      "Deploying...             \n"
    ].join)
  end
end
