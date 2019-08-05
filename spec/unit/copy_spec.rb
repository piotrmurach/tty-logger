# frozen_string_literal: true

RSpec.describe TTY::Logger, "#copy" do
  let(:output) { StringIO.new }
  let(:styles) { TTY::Logger::Handlers::Console::STYLES }

  it "copies ouptut, fields and configuration over to child logger" do
    logger = TTY::Logger.new(output: output, fields: {app: "parent"})
    child_logger = logger.copy(app: "child") do |config|
      config.filters = ["logging"]
    end

    logger.info("Parent logging")
    child_logger.warn("Child logging")

    expect(output.string).to eq([
      "\e[32m#{styles[:info][:symbol]}\e[0m ",
      "\e[32minfo\e[0m    ",
      "Parent logging            \e[32mapp\e[0m=parent\n",
      "\e[33m#{styles[:warn][:symbol]}\e[0m ",
      "\e[33mwarning\e[0m ",
      "Child [FILTERED]          \e[33mapp\e[0m=child\n"
    ].join)
  end
end
