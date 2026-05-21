# == Schema Information
#
# Table name: maintenances
# Database name: primary
#
#  id              :bigint           not null, primary key
#  cost            :integer
#  description     :text(65535)
#  discarded_at    :datetime
#  kind            :integer          default("routine"), not null
#  odometer_km     :integer
#  performed_on    :date             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discarded_by_id :bigint
#  performed_by_id :bigint
#  truck_id        :bigint           not null
#
# Indexes
#
#  index_maintenances_on_discarded_at     (discarded_at)
#  index_maintenances_on_discarded_by_id  (discarded_by_id)
#  index_maintenances_on_performed_by_id  (performed_by_id)
#  index_maintenances_on_performed_on     (performed_on)
#  index_maintenances_on_truck_id         (truck_id)
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (performed_by_id => users.id)
#  fk_rails_...  (truck_id => trucks.id)
#
class Maintenance < ApplicationRecord
  include Discardable
  audited

  enum :kind, { routine: 0, repair: 1, inspection: 2 }, default: :routine

  belongs_to :truck
  belongs_to :performed_by, class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :documents, as: :documentable, dependent: :restrict_with_error

  validates :performed_on, presence: true
  validates :cost,         numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :odometer_km,  numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
