require "rails_helper"

RSpec.describe Current do
  it "exposes a user accessor" do
    expect(described_class).to respond_to(:user)
  end
end
