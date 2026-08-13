# frozen_string_literal: true

# == Schema Information
#
# Table name: maintenances
# Database name: primary
#
#  id                  :bigint           not null, primary key
#  actual_duration     :decimal(8, 2)
#  cost                :integer
#  description         :text(65535)
#  discarded_at        :datetime
#  estimated_duration  :decimal(8, 2)
#  odometer_km         :integer
#  performed_on        :date             not null
#  state               :integer          default(0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  discarded_by_id     :bigint
#  maintenance_kind_id :bigint           not null
#  performed_by_id     :bigint
#  truck_id            :bigint           not null
#
# Indexes
#
#  index_maintenances_on_discarded_at         (discarded_at)
#  index_maintenances_on_discarded_by_id      (discarded_by_id)
#  index_maintenances_on_maintenance_kind_id  (maintenance_kind_id)
#  index_maintenances_on_performed_by_id      (performed_by_id)
#  index_maintenances_on_performed_on         (performed_on)
#  index_maintenances_on_truck_id             (truck_id)
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (maintenance_kind_id => maintenance_kinds.id)
#  fk_rails_...  (performed_by_id => users.id)
#  fk_rails_...  (truck_id => trucks.id)
#
class Maintenance < ApplicationRecord
  include Discardable
  audited

  enum :state, {started: 0, completed: 1}, default: :started

  belongs_to :truck
  belongs_to :maintenance_kind
  belongs_to :performed_by, class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :documents, as: :documentable, dependent: :restrict_with_error
  has_many :parts, class_name: "MaintenancePart", dependent: :restrict_with_error

  before_validation :assign_default_maintenance_kind

  validates :performed_on,   presence: true
  validates :cost,           numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_nil: true
  validates :odometer_km,    numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_nil: true
  validates :actual_duration,    numericality: {greater_than_or_equal_to: 0}, allow_nil: true
  validates :estimated_duration, numericality: {greater_than_or_equal_to: 0}, allow_nil: true

  # `kind` reads and writes through the maintenance_kind association by name,
  # so every existing caller that treated it as a plain string attribute (and
  # every values-restricted enum consumer) keeps working. Writing a name that
  # doesn't exist yet creates it — this is what lets the create-maintenance
  # drawer add new kinds inline instead of being limited to a fixed list.
  def kind
    maintenance_kind&.name
  end

  def kind=(name)
    self.maintenance_kind = name.present? ? ::MaintenanceKind.find_or_create_by!(name: name) : nil
  end

  def oil_change?
    kind == "oil_change"
  end

  # Cost is derived: it is the sum of the kept parts' prices. Callers mutate
  # parts, then recompute, rather than setting cost directly.
  def recompute_cost!
    update!(cost: parts.kept.sum(:price))
  end

  # Hours elapsed since the maintenance was opened. Used to stamp the actual
  # duration when the work is marked completed.
  def elapsed_hours
    ((Time.current - created_at) / 1.hour).round(2)
  end

  private

  def assign_default_maintenance_kind
    self.maintenance_kind ||= ::MaintenanceKind.find_or_create_by!(name: "routine")
  end
end
