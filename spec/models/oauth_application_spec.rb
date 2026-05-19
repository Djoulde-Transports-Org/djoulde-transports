require "rails_helper"

RSpec.describe OauthApplication do
  let(:valid_attrs) do
    {
      name: "test-app",
      redirect_uri: "https://example.com/callback",
      owner_type: "User",
      owner_id: 1
    }
  end

  it "is an ActiveRecord model" do
    expect(described_class.ancestors).to include(ActiveRecord::Base)
  end

  it "pulls in the Doorkeeper application mixin" do
    expect(described_class.ancestors.map(&:to_s))
      .to include("Doorkeeper::Orm::ActiveRecord::Mixins::Application")
  end

  it "is the application class Doorkeeper resolves to" do
    expect(Doorkeeper.config.application_class.to_s).to eq("OauthApplication")
  end

  describe "uniqueness of owner_id scoped to owner_type" do
    before { described_class.create!(valid_attrs) }

    let(:duplicate) { described_class.new(valid_attrs.merge(name: "second")) }

    it "rejects a second OauthApplication for the same owner" do
      expect(duplicate).not_to be_valid
    end

    it "attaches the error to owner_id" do
      duplicate.validate
      expect(duplicate.errors[:owner_id]).to be_present
    end
  end
end
