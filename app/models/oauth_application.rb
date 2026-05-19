class OauthApplication < ApplicationRecord
  include Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include Discardable

  self.table_name = "oauth_applications"

  belongs_to :owner, polymorphic: true, optional: true, inverse_of: :oauth_application
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :owner_id, uniqueness: { scope: :owner_type, allow_nil: true }
end
