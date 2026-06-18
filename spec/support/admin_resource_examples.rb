# frozen_string_literal: true

# Shared request-spec coverage for Active Admin resources. Including specs must
# define these `let`s:
#   model         - the AR class (e.g. Route)
#   record        - a persisted instance
#   create_params - params hash for a POST create (e.g. {route: {...}})
#   update_params - params hash for a PATCH update
# and may reference `admin` (the signed-in super admin) and `html`.
RSpec.shared_context "signed-in admin" do
  let(:html) { {"Accept" => "text/html"} }
  let(:admin) { create_admin }
  before { sign_in admin }
end

RSpec.shared_examples "a standard admin resource" do |path:|
  # The including describe must `include_context "signed-in admin"`; the let/
  # before defined there are inherited by this nested example group.
  it "renders the index" do
    record
    get "/admin/#{path}", headers: html
    expect(response).to have_http_status(:ok)
  end

  it "renders the show page" do
    get "/admin/#{path}/#{record.id}", headers: html
    expect(response).to have_http_status(:ok)
  end

  it "renders the new form" do
    get "/admin/#{path}/new", headers: html
    expect(response).to have_http_status(:ok)
  end

  it "renders the edit form" do
    get "/admin/#{path}/#{record.id}/edit", headers: html
    expect(response).to have_http_status(:ok)
  end

  it "creates a record", :aggregate_failures do
    expect { post "/admin/#{path}", params: create_params, headers: html }
      .to change(model, :count).by(1)
    expect(response).to have_http_status(:redirect)
  end

  it "updates a record" do
    record
    patch "/admin/#{path}/#{record.id}", params: update_params, headers: html
    expect(response).to have_http_status(:redirect)
  end
end

RSpec.shared_examples "a discardable admin resource" do |path:|
  it_behaves_like "a standard admin resource", path: path

  it "soft-deletes via discard and stamps discarded_by", :aggregate_failures do
    put "/admin/#{path}/#{record.id}/discard"
    expect(response).to have_http_status(:found)
    expect(record.reload).to be_discarded
    expect(record.discarded_by).to eq(admin)
  end

  it "restores via undiscard" do
    record.discard
    put "/admin/#{path}/#{record.id}/undiscard"
    expect(record.reload).not_to be_discarded
  end

  it "has no destroy route" do
    expect { Rails.application.routes.recognize_path("/admin/#{path}/#{record.id}", method: :delete) }
      .to raise_error(ActionController::RoutingError)
  end
end
