# frozen_string_literal: true

# == Schema Information
#
# Table name: tanks
# Database name: primary
#
#  id              :bigint           not null, primary key
#  capacity        :integer          not null
#  discarded_at    :datetime
#  make            :string(255)
#  model           :string(255)
#  plate_number    :string(255)      not null
#  status          :integer          default("active"), not null
#  vin             :string(255)
#  year            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discarded_by_id :bigint
#  truck_id        :bigint           not null
#
# Indexes
#
#  index_tanks_on_discarded_at     (discarded_at)
#  index_tanks_on_discarded_by_id  (discarded_by_id)
#  index_tanks_on_plate_number     (plate_number) UNIQUE
#  index_tanks_on_truck_id         (truck_id) UNIQUE
#  index_tanks_on_vin              (vin) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (truck_id => trucks.id)
#
class Tank < ApplicationRecord
  include Discardable
  audited

  enum :status, {active: 0, out_of_service: 1}, default: :active

  belongs_to :truck
  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :trips,     dependent: :restrict_with_error
  has_many :documents, as: :documentable, dependent: :restrict_with_error

  validates :plate_number, presence: true, uniqueness: {case_sensitive: false}
  validates :vin, uniqueness: {case_sensitive: false, allow_blank: true}
  validates :truck_id, uniqueness: true
  validates :year, numericality: {only_integer: true, greater_than: 1900,
                                    less_than_or_equal_to: ->(_t) { Time.zone.today.year + 1 }},
                   allow_nil: true
  validates :capacity, presence: true,
                              numericality: {only_integer: true, greater_than: 0}
end
