# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  discarded_at           :datetime
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  locked_at              :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string(255)
#  unlock_token           :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  discarded_by_id        :bigint
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_discarded_at          (discarded_at)
#  index_users_on_discarded_by_id       (discarded_by_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#
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
