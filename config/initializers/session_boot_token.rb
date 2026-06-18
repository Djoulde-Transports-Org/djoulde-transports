# frozen_string_literal: true

# Sessions are stored in signed cookies (Devise + Rails CookieStore), so they
# normally survive a server restart. This invalidates every session whenever a
# new release is deployed (or the app restarts): the token below is stamped onto
# each session at sign-in, and any session carrying a different token fails
# authentication and the user is forced to sign in again.
#
# The token is pinned to the release so it is identical across every Puma worker
# and Kamal container of the same deploy — users stay logged in during normal
# traffic, but a redeploy/restart ends all sessions. In local dev (no release id)
# it falls back to a per-process random value, so restarting the server logs out.
#
# Paired with the controller check in ApplicationController#authenticate_admin!.
# Stored under config.x (Rails' namespace for custom settings) so an unset key
# returns nil instead of raising NoMethodError.
Rails.application.config.x.session_boot_token =
  ENV["RELEASE_ID"] || ENV["KAMAL_VERSION"] || SecureRandom.hex(32)

# Registered once at boot (not in to_prepare, which would re-add the hook on
# every code reload). `except: :fetch` runs on a real authentication (sign-in),
# not on requests that rehydrate an existing session, so the token is only
# stamped when a new session is established.
Warden::Manager.after_set_user except: :fetch do |_user, auth, _opts|
  # Write to the top-level rack session so the controller can read it back as
  # session[:boot_token]. (auth.session(scope) would write Warden's scoped
  # sub-hash, which the controller does not read.)
  auth.raw_session[:boot_token] = Rails.application.config.x.session_boot_token
end
