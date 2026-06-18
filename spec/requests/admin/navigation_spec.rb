# frozen_string_literal: true

# Ticket 12: the admin landing page is the trips index (the default dashboard
# was removed). Per-resource pages are covered by their own specs.
RSpec.describe "Admin navigation", type: :request do
  let(:html) { {"Accept" => "text/html"} }

  it "routes /admin to the trips index" do
    expect(Rails.application.routes.recognize_path("/admin"))
      .to eq(controller: "admin/trips", action: "index")
  end

  it "renders the trips index at the root" do
    sign_in create_admin
    get "/admin", headers: html
    expect(response).to have_http_status(:ok)
  end
end
