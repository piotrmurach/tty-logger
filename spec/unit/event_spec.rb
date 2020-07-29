# frozen_string_literal: true

RSpec.describe TTY::Logger::Event, "event" do
  it "defaults backtrace to an empty array" do
    event = described_class.new(["message"])

    expect(event.message).to eq(["message"])
    expect(event.fields).to eq({})
    expect(event.metadata).to eq({})
    expect(event.backtrace).to eq([])
  end

  it "extracts only message from an exception" do
    error = ArgumentError.new("Wrong data")
    event = described_class.new([error])

    expect(event.message).to eq([error])
    expect(event.backtrace).to eq([])
  end

  it "extracts backtrace if message contains exception" do
    event = nil
    error = ArgumentError.new("Wrong data")

    begin
      raise error
    rescue => ex
      error = ex
      event = described_class.new(["Error", ex], {}, {})
    end

    expect(event.message).to eq(["Error", error])
    expect(event.backtrace.join).to eq(error.backtrace.join)
  end
end
