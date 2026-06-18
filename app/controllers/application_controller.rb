# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Active Admin (ticket 12) session auth. There is no separate AdminUser
  # model: an admin is a Devise `User` that carries the `super_admin` Rolify
  # role. `authenticate_admin!` is Active Admin's authentication_method, run as
  # a before_action on every admin controller; `current_admin` is its
  # current_user_method.
  def authenticate_admin!
    authenticate_user!
    return unless current_user

    # Sessions do not survive a server restart: a session stamped with a token
    # from an earlier boot is invalid, so force a fresh sign-in. See
    # config/initializers/session_boot_token.rb.
    if session[:boot_token] != Rails.application.config.x.session_boot_token
      sign_out(current_user)
      redirect_to new_user_session_path,
        alert: "Your session expired. Please sign in again to continue."
      return
    end

    return if current_user.has_role?(:super_admin)

    redirect_to new_user_session_path,
      alert: "You are not authorized to access the admin area."
  end

  def current_admin
    current_user if current_user&.has_role?(:super_admin)
  end

  # Land on the admin area after signing in (honoring any page the user was
  # originally headed to), instead of Devise's default root path.
  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || admin_root_path
  end

  # Send users back to the login page after signing out instead of Devise's
  # default root path.
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
