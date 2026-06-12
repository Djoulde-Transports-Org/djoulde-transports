# frozen_string_literal: true

RSpec.describe User do
  let(:password) { "correct horse battery staple" }
  let(:user) do
    described_class.create!(email: "u@example.com", password: password)
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "authenticates a valid password" do
    expect(user.valid_password?(password)).to be(true)
  end

  it "auto-confirms users in the test environment" do
    expect(user.confirmed?).to be(true)
  end

  it "exposes the rolify role API" do
    expect(user).to respond_to(:add_role)
  end

  it "associates has_one :oauth_application with polymorphic :owner" do
    reflection = described_class.reflect_on_association(:oauth_application)
    expect(reflection.options[:as]).to eq(:owner)
  end

  describe "#active_for_authentication?" do
    it "is true for an undiscarded user" do
      expect(user.active_for_authentication?).to be(true)
    end

    it "is false once the user is discarded" do
      user.discard
      expect(user.active_for_authentication?).to be(false)
    end
  end

  describe "#inactive_message" do
    it "returns :discarded when the user is discarded" do
      user.discard
      expect(user.inactive_message).to eq(:discarded)
    end
  end

  describe "discard cascade to oauth_application" do
    let!(:app) do
      OauthApplication.create!(name: "spa", redirect_uri: "https://example.com/cb", owner: user)
    end

    it "discards the user's OauthApplication when the user is discarded" do
      user.discard
      expect(app.reload.discarded?).to be(true)
    end
  end
end
