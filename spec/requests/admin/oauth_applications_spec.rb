# frozen_string_literal: true

# Ticket 12: OauthApplication admin. Each app is owned by one User; the create
# form stamps the acting admin as created_by and a second app for the same
# owner is rejected with a friendly validation error rather than a 500.
RSpec.describe "Admin oauth applications", type: :request do
  let(:admin) { create_admin }
  let(:owner) { User.create!(email: "owner-#{SecureRandom.hex(2)}@example.com", password: AdminAuth::PASSWORD) }

  before { sign_in admin }

  def create_params(owner_user)
    {
      oauth_application: {
        name: "spa-app",
        redirect_uri: "https://example.com/cb",
        owner_id: owner_user.id,
        owner_type: "User",
        scopes: "",
      },
    }
  end

  it "creates an application for a user and stamps created_by", :aggregate_failures do
    post "/admin/oauth_applications", params: create_params(owner)

    app = OauthApplication.find_by(name: "spa-app")
    expect(app).to be_present
    expect(app.owner).to eq(owner)
    expect(app.created_by).to eq(admin)
  end

  it "rejects a second application for the same owner without a 500", :aggregate_failures do
    OauthApplication.create!(name: "first", redirect_uri: "https://example.com/cb", owner: owner)

    post "/admin/oauth_applications", params: create_params(owner)

    expect(response.status).to be_in([ 200, 422 ])
    expect(OauthApplication.where(owner_id: owner.id).count).to eq(1)
  end
end
