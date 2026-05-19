class OauthApplication < ApplicationRecord
  include Doorkeeper::Orm::ActiveRecord::Mixins::Application
  # TODO(ticket-07): include Discardable once that concern lands on master.
  # The discarded_at + discarded_by_id columns already exist on this table.

  self.table_name = "oauth_applications"

  belongs_to :owner, polymorphic: true, optional: true, inverse_of: :oauth_application
  belongs_to :created_by, class_name: "User", optional: true

  validates :owner_id, uniqueness: { scope: :owner_type, allow_nil: true }
end
