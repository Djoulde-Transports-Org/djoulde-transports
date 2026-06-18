# frozen_string_literal: true

# Ticket 12: audit admin page is read-only (index + show only); audits are
# written by the `audited` gem as a side effect of model changes.
RSpec.describe "Admin audits", type: :request do
  let(:html) { {"Accept" => "text/html"} }

  before { sign_in create_admin }

  it "renders the index" do
    build_truck # an audited model change produces an audit row
    get "/admin/audits", headers: html
    expect(response).to have_http_status(:ok)
  end

  it "renders the show page" do
    build_truck
    audit = Audited::Audit.order(:id).last
    get "/admin/audits/#{audit.id}", headers: html
    expect(response).to have_http_status(:ok)
  end

  it "does not expose a new form" do
    get "/admin/audits/new", headers: html
    expect(response).to have_http_status(:not_found)
  end
end
