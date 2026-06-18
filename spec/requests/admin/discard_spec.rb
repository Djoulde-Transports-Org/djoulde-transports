# frozen_string_literal: true

# Ticket 12: the shared Discardable admin behaviour — soft-delete from the
# admin UI stamps discarded_by with the acting admin, there is no destroy
# route, and access is gated to super_admins.
RSpec.describe "Admin discard", type: :request do
  let(:route) { Route.create!(origin: "Conakry", destination: "Labe", rate: 250) }

  it "soft-deletes the record and stamps discarded_by with the acting admin", :aggregate_failures do
    admin = create_admin
    sign_in admin

    put "/admin/routes/#{route.id}/discard"

    expect(response).to have_http_status(:found)
    route.reload
    expect(route).to be_discarded
    expect(route.discarded_by).to eq(admin)
  end

  it "restores a discarded record" do
    admin = create_admin
    sign_in admin
    route.discard

    put "/admin/routes/#{route.id}/undiscard"

    expect(route.reload).not_to be_discarded
  end

  it "does not expose a destroy route" do
    expect { Rails.application.routes.recognize_path("/admin/routes/#{route.id}", method: :delete) }
      .to raise_error(ActionController::RoutingError)
  end

  it "redirects a signed-in non-admin away from the admin area" do
    plain = User.create!(email: "plain@example.com", password: AdminAuth::PASSWORD)
    sign_in plain

    get "/admin/routes", headers: {"Accept" => "text/html"}

    expect(response).to redirect_to(new_user_session_path)
  end

  it "redirects an anonymous visitor to the login page" do
    get "/admin/routes", headers: {"Accept" => "text/html"}
    expect(response).to redirect_to(new_user_session_path)
  end
end
