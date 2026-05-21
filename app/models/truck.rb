class Truck < ApplicationRecord
  include Discardable
  audited

  enum :status, { active: 0, out_of_service: 1 }, default: :active

  belongs_to :created_by,    class_name: "User", optional: true
  belongs_to :discarded_by,  class_name: "User", optional: true

  has_many :trips,        dependent: :restrict_with_error
  has_many :maintenances, dependent: :restrict_with_error
  has_many :documents, as: :documentable, dependent: :restrict_with_error

  validates :plate_number, presence: true, uniqueness: { case_sensitive: false }
  validates :vin, uniqueness: { case_sensitive: false, allow_blank: true }
  validates :year, numericality: { only_integer: true, greater_than: 1900,
                                    less_than_or_equal_to: ->(_t) { Date.current.year + 1 } },
                   allow_nil: true
  validates :capacity_kg, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
