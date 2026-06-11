# frozen_string_literal: true

RSpec.describe Current do
  it "exposes a user accessor" do
    expect(described_class).to respond_to(:user)
  end
end
