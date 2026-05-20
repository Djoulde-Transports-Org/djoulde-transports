class User < ApplicationRecord
  include Discardable
  rolify

  devise :database_authenticatable,
         :confirmable,
         :lockable,
         :trackable,
         :recoverable

  has_one :oauth_application,
          class_name: "OauthApplication",
          as: :owner,
          inverse_of: :owner,
          dependent: :restrict_with_error

  belongs_to :discarded_by, class_name: "User", optional: true

  after_discard :discard_oauth_application
  before_validation :auto_confirm_in_dev_and_test, on: :create

  def active_for_authentication?
    super && !discarded?
  end

  def inactive_message
    discarded? ? :discarded : super
  end

  private

  def discard_oauth_application
    oauth_application&.discard
  end

  def auto_confirm_in_dev_and_test
    return unless Rails.env.development? || Rails.env.test?

    skip_confirmation!
    skip_confirmation_notification!
  end
end
