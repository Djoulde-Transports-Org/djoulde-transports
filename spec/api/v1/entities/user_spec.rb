# frozen_string_literal: true

RSpec.describe API::V1::Entities::User do
  let(:user) { User.create!(email: "entity@example.com", password: "correct horse battery staple") }
  let(:payload) { described_class.represent(user).as_json }

  it "exposes the id" do
    expect(payload[:id]).to eq(user.id)
  end

  it "exposes the email" do
    expect(payload[:email]).to eq(user.email)
  end

  context "with no roles assigned" do
    it "exposes an empty roles array" do
      expect(payload[:roles]).to eq([])
    end
  end

  context "with roles assigned" do
    before do
      user.add_role(:super_admin)
      user.add_role(:auditor)
    end

    it "exposes role names as strings" do
      expect(payload[:roles]).to match_array(%w(super_admin auditor))
    end
  end
end
