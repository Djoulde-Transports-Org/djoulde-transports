# frozen_string_literal: true

# Idempotent seeds, safe to run on every deploy / dev refresh.

# Ticket 09: Rolify roles. Active Admin (ticket 12) assigns these to users.
%w(super_admin dispatcher billing maintenance driver_readonly).each do |name|
  Role.find_or_create_by!(name: name)
end

# Ticket 02: Postman QA data for the trucks API. Creates an admin + a
# read-only user, each with an OauthApplication they own (auth requires
# `app.owner_id == current_user.id`) and a non-revoked access token. Also
# seeds a few trucks so list/get/update/delete have something to hit.
DEMO_PASSWORD = "correct horse battery staple"

demo_users = {
  super_admin:     "admin@djoulde.test",
  driver_readonly: "viewer@djoulde.test",
}.map do |role, email|
  user = User.find_or_initialize_by(email: email)
  user.password = DEMO_PASSWORD if user.new_record?
  user.save!
  user.add_role(role) unless user.has_role?(role)
  user
end

admin, _viewer = demo_users

demo_tokens = demo_users.to_h do |user|
  app = OauthApplication.find_or_create_by!(owner: user) do |a|
    a.name         = "postman-#{user.email}"
    a.redirect_uri = "https://example.com/cb"
  end
  token = Doorkeeper::AccessToken.where(
    application_id:    app.id,
    resource_owner_id: user.id,
    revoked_at:        nil,
  ).first || Doorkeeper::AccessToken.create!(
    application_id:    app.id,
    resource_owner_id: user.id,
    scopes:            "default",
  )
  [ user.email, token.token ]
end

[
  {plate_number: "TRK-001", vin: "VIN-DEMO-001", make: "Volvo",    model: "FH16",   year: 2020},
  {plate_number: "TRK-002", vin: "VIN-DEMO-002", make: "Scania",   model: "R500",   year: 2021},
  {plate_number: "TRK-003", vin: "VIN-DEMO-003", make: "Mercedes", model: "Actros", year: 2022},
].each do |attrs|
  Truck.find_or_create_by!(plate_number: attrs[:plate_number]) do |t|
    t.assign_attributes(attrs)
    t.created_by = admin
  end
end

puts "\n== Trucks API: Postman QA credentials =="
puts "   Password for all demo users: #{DEMO_PASSWORD}"
demo_tokens.each do |email, token|
  puts "   #{email.ljust(28)} Bearer #{token}"
end
puts
