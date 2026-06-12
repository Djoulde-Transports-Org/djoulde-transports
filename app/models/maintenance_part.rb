# frozen_string_literal: true

# == Schema Information
#
# Table name: maintenance_parts
# Database name: primary
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  name            :string(255)      not null
#  price           :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discarded_by_id :bigint
#  maintenance_id  :bigint           not null
#
# Indexes
#
#  index_maintenance_parts_on_discarded_at     (discarded_at)
#  index_maintenance_parts_on_discarded_by_id  (discarded_by_id)
#  index_maintenance_parts_on_maintenance_id   (maintenance_id)
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (maintenance_id => maintenances.id)
#
class MaintenancePart < ApplicationRecord
  include Discardable
  audited associated_with: :maintenance

  belongs_to :maintenance
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :name, presence: true
  validates :price, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
