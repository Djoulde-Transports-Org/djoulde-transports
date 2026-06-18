# frozen_string_literal: true

RSpec.describe "Admin roles", type: :request do
  include_context "signed-in admin"
  let(:model) { Role }
  let(:record) { build_role }
  let(:create_params) { {role: {name: "role-#{SecureRandom.hex(3)}"}} }
  let(:update_params) { {role: {name: "renamed-#{SecureRandom.hex(3)}"}} }

  it_behaves_like "a standard admin resource", path: "roles"

  it "applies the update" do
    record
    new_name = "renamed-#{SecureRandom.hex(3)}"
    patch "/admin/roles/#{record.id}", params: {role: {name: new_name}}
    expect(record.reload.name).to eq(new_name)
  end

  it "does not expose a destroy route" do
    expect { Rails.application.routes.recognize_path("/admin/roles/#{record.id}", method: :delete) }
      .to raise_error(ActionController::RoutingError)
  end
end
