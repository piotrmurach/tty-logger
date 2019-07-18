# frozen_string_literal: true

RSpec.describe TTY::Logger::Formatters::JSON, "#dump" do
  it "dumps a log line" do
    formatter = described_class.new
    data = {
      app: "myapp",
      env: "prod",
      sql: "SELECT * FROM admins",
      at: Time.at(123456).utc
    }

    expect(formatter.dump(data)).to eq("{\"app\":\"myapp\",\"env\":\"prod\",\"sql\":\"SELECT * FROM admins\",\"at\":\"1970-01-02 10:17:36 UTC\"}")
  end

  [
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 3*12+2, want: "{\"a\":\"aaaaa\",\"b\":\"bbbbb\",\"c\":\"ccccc\"}"},
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 2*12+4, want: "{\"a\":\"aaaaa\",\"b\":\"bbbbb\",\"c\":\"...\"}"},
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 12+4, want: "{\"a\":\"aaaaa\",\"b\":\"...\"}"},
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 11, want: "{\"a\":\"...\"}"},
  ].each do |data|
    it "truncates #{data[:obj].inspect} to #{data[:want].inspect} of #{data[:bytes]} bytes" do
      formatter = described_class.new
      expect(formatter.dump(data[:obj], max_bytes: data[:bytes])).to eq(data[:want])
    end
  end

  [
    {obj: {a: {b: {c: "ccccc"}}}, depth: 1, want: "{\"a\":\"...\"}"},
    {obj: {a: {b: {c: "ccccc"}}}, depth: 2, want: "{\"a\":{\"b\":\"...\"}}"},
    {obj: {a: {b: {c: "ccccc"}}}, depth: 3, want: "{\"a\":{\"b\":{\"c\":\"ccccc\"}}}"},
    {obj: {a: ["b", {c: "ccccc"}]}, depth: 1, want: "{\"a\":\"...\"}"},
    {obj: {a: ["b", {c: "ccccc"}]}, depth: 2, want: "{\"a\":[\"b\",\"...\"]}"},
    {obj: {a: ["b", {c: "ccccc"}]}, depth: 3, want: "{\"a\":[\"b\",{\"c\":\"ccccc\"}]}"},
  ].each do |data|
    it "truncates nested object #{data[:obj].inspect} to #{data[:want].inspect}" do
      formatter = described_class.new
      expect(formatter.dump(data[:obj], max_depth: data[:depth])).to eq(data[:want])
    end
  end
end
