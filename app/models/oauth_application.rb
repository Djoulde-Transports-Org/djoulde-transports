# == Schema Information
#
# Table name: oauth_applications
# Database name: primary
#
#  id              :bigint           not null, primary key
#  calls_count     :integer          default(0), not null
#  confidential    :boolean          default(TRUE), not null
#  discarded_at    :datetime
#  last_used_at    :datetime
#  name            :string(255)      not null
#  owner_type      :string(255)
#  redirect_uri    :text(65535)      not null
#  scopes          :string(255)      default(""), not null
#  secret          :string(255)      not null
#  uid             :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :bigint
#  discarded_by_id :bigint
#  owner_id        :bigint
#
# Indexes
#
#  index_oauth_applications_on_created_by_id            (created_by_id)
#  index_oauth_applications_on_discarded_at             (discarded_at)
#  index_oauth_applications_on_discarded_by_id          (discarded_by_id)
#  index_oauth_applications_on_owner_type_and_owner_id  (owner_type,owner_id) UNIQUE
#  index_oauth_applications_on_uid                      (uid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (discarded_by_id => users.id)
#
class OauthApplication < ApplicationRecord
  include Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include Discardable

  self.table_name = "oauth_applications"

  belongs_to :owner, polymorphic: true, optional: true, inverse_of: :oauth_application
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :owner_id, uniqueness: { scope: :owner_type, allow_nil: true }
end
