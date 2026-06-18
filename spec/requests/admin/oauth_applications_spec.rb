# frozen_string_literal: true

# Ticket 12: OauthApplication admin. Each app is owned by one User; the create
# form stamps the acting admin as created_by and a second app for the same
# owner is rejected with a friendly validation error rather than a 500.
RSpec.describe "Admin oauth applications", type: :request do
  include_context "signed-in admin"
  let(:owner) { User.create!(email: "owner-#{SecureRandom.hex(3)}@example.com", password: AdminAuth::PASSWORD) }

  let(:model) { OauthApplication }
  let(:record) do
    OauthApplication.create!(name: "existing", redirect_uri: "https://example.com/cb", owner: owner)
  end
  let(:create_params) do
    fresh_owner = User.create!(email: "owner-#{SecureRandom.hex(3)}@example.com", password: AdminAuth::PASSWORD)
    {oauth_application: {name: "spa-#{SecureRandom.hex(3)}", redirect_uri: "https://example.com/cb",
                         owner_id: fresh_owner.id, owner_type: "User", scopes: ""}}
  end
  let(:update_params) { {oauth_application: {name: "renamed-#{SecureRandom.hex(3)}"}} }

  it_behaves_like "a discardable admin resource", path: "oauth_applications"

  it "stamps created_by with the acting admin on create", :aggregate_failures do
    post "/admin/oauth_applications", params: create_params
    app = OauthApplication.order(:id).last
    expect(app.created_by).to eq(admin)
  end

  it "rejects a second application for the same owner without a 500", :aggregate_failures do
    OauthApplication.create!(name: "first", redirect_uri: "https://example.com/cb", owner: owner)
    post "/admin/oauth_applications",
      params: {oauth_application: {name: "second", redirect_uri: "https://example.com/cb",
                                   owner_id: owner.id, owner_type: "User", scopes: ""}}
    expect(response.status).to be_in([ 200, 422 ])
    expect(OauthApplication.where(owner_id: owner.id).count).to eq(1)
  end
end
