# frozen_string_literal: true

RSpec.describe TTY::Logger::Formatters::Text, "#dump" do

  [
    {key: "k", value: "v", want: "k=v"},
    {key: "k", value: '\n', want: "k=\\n"},
    {key: "k", value: '\r', want: "k=\\r"},
    {key: "k", value: '\t', want: "k=\\t"},
    {key: "k", value: "null", want: "k=\"null\""},
    {key: "k", value: "", want: "k="},
    {key: "k", value: true, want: "k=true"},
    {key: "k", value: "true", want: "k=\"true\""},
    {key: "k", value: "false", want: "k=\"false\""},
    {key: "k", value: 1, want: "k=1"},
    {key: "k", value: 1.035, want: "k=1.035"},
    {key: "k", value: 1e-5, want: "k=0.00001"},
    {key: "k", value: Complex(2,1), want: "k=(2+1i)"},
    {key: "k", value: "1", want: "k=\"1\""},
    {key: "k", value: "1.035", want: "k=\"1.035\""},
    {key: "k", value: "1e-5", want: "k=\"1e-5\""},
    {key: "k", value: "v v", want: "k=\"v v\""},
    {key: "k", value: " ", want: 'k=" "'},
    {key: "k", value: '"', want: 'k="\""'},
    {key: "k", value: '=', want: 'k="="'},
    {key: "k", value: "\\", want: "k=\\"},
    {key: "k", value: "=\\", want: "k=\"=\\\\\""},
    {key: "k", value: "\\\"", want: "k=\"\\\\\\\"\""},
    {key: "k", value: Time.new(2019, 7, 7, 12, 21, 35, "+02:00"), want: "k=2019-07-07T12:21:35+02:00"},
    {key: "k", value: {a: 1}, want: "k={a=1}"},
    {key: "k", value: {a: 1, b: 2}, want: "k={a=1 b=2}"},
    {key: "k", value: {a: {b: 2}}, want: "k={a={b=2}}"},
    {key: "k", value: ["a", 1], want: "k=[a 1]"},
    {key: "k", value: ["a", ["b", 2], 1], want: "k=[a [b 2] 1]"},
  ].each do |data|
    it "dumps {#{data[:key].inspect} => #{data[:value].inspect}} as #{data[:want].inspect}" do
      formatter = described_class.new
      expect(formatter.dump({data[:key] => data[:value]})).to eq(data[:want])
    end
  end

  it "dumps a log line" do
    formatter = described_class.new
    data = {
      app: "myapp",
      env: "prod",
      sql: "SELECT * FROM admins",
      at: Time.at(123456).utc
    }

    expect(formatter.dump(data)).to eq("app=myapp env=prod sql=\"SELECT * FROM admins\" at=1970-01-02T10:17:36+00:00")
  end
end
