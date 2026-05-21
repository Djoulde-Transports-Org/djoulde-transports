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
