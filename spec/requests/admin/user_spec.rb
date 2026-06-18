# frozen_string_literal: true

RSpec.describe "Admin users", type: :request do
  include_context "signed-in admin"
  let(:model) { User }
  let(:record) { User.create!(email: "u-#{SecureRandom.hex(3)}@example.com", password: AdminAuth::PASSWORD) }
  let(:create_params) do
    {user: {email: "new-#{SecureRandom.hex(3)}@example.com",
            password: AdminAuth::PASSWORD, password_confirmation: AdminAuth::PASSWORD}}
  end
  let(:update_params) { {user: {role_ids: [ build_role.id ]}} }

  it_behaves_like "a discardable admin resource", path: "users"

  it "assigns roles on update" do
    role = build_role
    patch "/admin/users/#{record.id}", params: {user: {role_ids: [ role.id ]}}
    expect(record.reload.roles).to include(role)
  end

  it "keeps the current password when updating with a blank password", :aggregate_failures do
    role = build_role
    patch "/admin/users/#{record.id}",
      params: {user: {password: "", password_confirmation: "", role_ids: [ role.id ]}}
    record.reload
    expect(record.valid_password?(AdminAuth::PASSWORD)).to be(true)
    expect(record.roles).to include(role)
  end
end
