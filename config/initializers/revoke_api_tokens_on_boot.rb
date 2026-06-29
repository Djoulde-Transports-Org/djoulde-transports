# frozen_string_literal: true

# API bearer tokens (Doorkeeper) are invalidated on every server restart,
# forcing clients to re-authenticate. Mirrors the session_boot_token strategy
# used for admin cookie sessions (see session_boot_token.rb).
#
# In production, a deploy boots a new process and immediately invalidates
# tokens issued under the previous binary. In local dev, any `docker compose
# up` / `rails s` clears all tokens.
Rails.application.config.after_initialize do
  Doorkeeper::AccessToken.delete_all
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  # DB not ready (first boot before db:create / db:migrate). Safe to skip.
end
