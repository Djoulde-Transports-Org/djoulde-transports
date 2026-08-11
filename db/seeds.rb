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

demo_trucks = [
  {plate_number: "TRK-001", vin: "VIN-DEMO-001", make: "Volvo",    model: "FH16",   year: 2020},
  {plate_number: "TRK-002", vin: "VIN-DEMO-002", make: "Scania",   model: "R500",   year: 2021},
  {plate_number: "TRK-003", vin: "VIN-DEMO-003", make: "Mercedes", model: "Actros", year: 2022},
].map do |attrs|
  Truck.find_or_create_by!(plate_number: attrs[:plate_number]) do |t|
    t.assign_attributes(attrs)
    t.created_by = admin
  end
end

# DT-020: mock billing data so the billing cards view and the billing_line_items
# admin table have something realistic to show. One statement per status
# (paid / issued / draft), each backed by a real trip + delivery note so its
# line items and totals are computed the same way production billing would.
demo_trucks.each do |truck|
  next if truck.tank.present?

  Tank.create!(truck: truck, plate_number: "TNK-#{truck.plate_number.delete_prefix('TRK-')}",
    capacity: 30_000)
  truck.reload
end

demo_routes = [
  {origin: "Conakry", destination: "Kindia", rate: 220},
  {origin: "Conakry", destination: "Labe",   rate: 340},
].map do |attrs|
  Route.find_or_create_by!(origin: attrs[:origin], destination: attrs[:destination]) do |r|
    r.rate = attrs[:rate]
  end
end

billing_plan = [
  {months_ago: 3, status: :paid},
  {months_ago: 2, status: :issued},
  {months_ago: 1, status: :draft},
]

demo_statements = billing_plan.each_with_index.map do |cfg, i|
  month = Time.zone.today.prev_month(cfg[:months_ago]).beginning_of_month
  statement = BillingStatement.for_month(month).first

  if statement.nil?
    trip = Trip.create!(
      truck: demo_trucks[i % demo_trucks.size],
      route: demo_routes[i % demo_routes.size],
      status: :completed,
      actual_start_at: month + 5.days,
      actual_end_at: month + 5.days + 6.hours,
    )
    DeliveryNote.create!(trip: trip, number: "DN-SEED-#{month.strftime('%Y%m')}",
      gasoline_quantity: 8_000, diesel_quantity: 12_000)
    statement = Billing::DraftMonthlyStatement.call(month: month)
  end

  if cfg[:status].in?([ :issued, :paid ]) && statement.draft?
    statement.recalculate_total!
    statement.update!(status: :issued, issued_on: statement.issue_window.first + 3.days)
  end
  statement.update!(status: :paid) if cfg[:status] == :paid && !statement.paid?

  statement
end

puts "\n== Billing: mock statements for the billing cards view =="
demo_statements.each do |s|
  puts "   #{s.number.ljust(10)} #{s.status.ljust(8)} grand_total=#{s.grand_total}"
end

puts "\n== Trucks API: Postman QA credentials =="
puts "   Password for all demo users: #{DEMO_PASSWORD}"
demo_tokens.each do |email, token|
  puts "   #{email.ljust(28)} Bearer #{token}"
end
puts
