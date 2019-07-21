# frozen_string_literal: true

RSpec.describe TTY::Logger::Event, "event" do
  it "defaults backtrace to an empty array" do
    event = described_class.new(["message"], {}, {})
    expect(event.backtrace).to eq([])
  end

  it "extracts backtrace if message contains exception" do
    event = nil
    error = nil

    begin
      raise ArgumentError, "Wrong data"
    rescue => ex
      error = ex
      event = described_class.new(["Error", ex], {}, {})
    end

    expect(event.backtrace.join).to eq(error.backtrace.join)
  end
end
