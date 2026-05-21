# == Schema Information
#
# Table name: routes
# Database name: primary
#
#  id              :bigint           not null, primary key
#  destination     :string(255)      not null
#  discarded_at    :datetime
#  origin          :string(255)      not null
#  rate            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discarded_by_id :bigint
#
# Indexes
#
#  index_routes_on_discarded_at            (discarded_at)
#  index_routes_on_discarded_by_id         (discarded_by_id)
#  index_routes_on_origin_and_destination  (origin,destination) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#

class Route < ApplicationRecord
  include Discardable
  audited

  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :trips, dependent: :restrict_with_error

  validates :origin, :destination, presence: true
  validates :origin, uniqueness: { scope: :destination, case_sensitive: false }
  validates :rate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
