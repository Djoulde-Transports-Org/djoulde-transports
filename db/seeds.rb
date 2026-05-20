# Idempotent seeds — safe to run on every deploy / dev refresh.

# Ticket 09: Rolify roles. Active Admin (ticket 12) assigns these to users.
%w[super_admin dispatcher billing maintenance driver_readonly].each do |name|
  Role.find_or_create_by!(name: name)
end
