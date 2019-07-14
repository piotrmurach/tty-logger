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
end
