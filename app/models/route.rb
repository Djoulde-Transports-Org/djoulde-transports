class Route < ApplicationRecord
  include Discardable
  audited

  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :trips, dependent: :restrict_with_error

  validates :origin, :destination, presence: true
  validates :origin, uniqueness: { scope: :destination, case_sensitive: false }
  validates :rate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
