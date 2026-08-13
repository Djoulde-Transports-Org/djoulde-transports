# frozen_string_literal: true

# == Schema Information
#
# Table name: maintenance_kinds
# Database name: primary
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discarded_by_id :bigint
#
# Indexes
#
#  index_maintenance_kinds_on_discarded_at     (discarded_at)
#  index_maintenance_kinds_on_discarded_by_id  (discarded_by_id)
#  index_maintenance_kinds_on_name             (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#
class MaintenanceKind < ApplicationRecord
  include Discardable
  audited

  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :maintenances, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: {case_sensitive: false}
end
