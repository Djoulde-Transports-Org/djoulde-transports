module SetsCurrentUser
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    Current.user = respond_to?(:current_user, true) ? current_user : nil
  end
end
