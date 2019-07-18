# frozen_string_literal: true

RSpec.describe TTY::Logger::Handlers::Null, "custom handler" do
  let(:output) { StringIO.new }

  it "logs messages with a custom handler" do
    stub_const("MyHandler", Class.new do
      def initialize(output: nil, config: nil, label: nil)
        @label = label
        @output = output
      end

      def call(event)
        @output.puts "(#{@label}) #{event.message.join}"
      end
    end)

    logger = TTY::Logger.new(output: output) do |config|
      config.handlers = [[MyHandler, {label: "myhandler"}]]
    end

    logger.info("Logging")

    expect(output.string).to eq("(myhandler) Logging\n")
  end
end
