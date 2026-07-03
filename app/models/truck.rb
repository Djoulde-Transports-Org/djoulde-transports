# frozen_string_literal: true

# == Schema Information
#
# Table name: trucks
# Database name: primary
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  make            :string(255)
#  model           :string(255)
#  plate_number    :string(255)      not null
#  status          :integer          default("ready"), not null
#  vin             :string(255)
#  year            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :bigint
#  discarded_by_id :bigint
#  driver_id       :bigint
#
# Indexes
#
#  index_trucks_on_created_by_id    (created_by_id)
#  index_trucks_on_discarded_at     (discarded_at)
#  index_trucks_on_discarded_by_id  (discarded_by_id)
#  index_trucks_on_driver_id        (driver_id) UNIQUE
#  index_trucks_on_plate_number     (plate_number) UNIQUE
#  index_trucks_on_vin              (vin) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (driver_id => employees.id)
#
class Truck < ApplicationRecord
  include Discardable
  audited

  enum :status, {ready: 0, in_maintenance: 1, on_trip: 2}, default: :ready

  belongs_to :created_by,    class_name: "User", optional: true
  belongs_to :discarded_by,  class_name: "User", optional: true
  belongs_to :driver,        class_name: "Employee", optional: true, inverse_of: :truck

  has_one  :tank,         dependent: :restrict_with_error
  has_many :trips,        dependent: :restrict_with_error
  has_many :maintenances, dependent: :restrict_with_error
  has_many :documents, as: :documentable, dependent: :restrict_with_error

  validates :plate_number, presence: true, uniqueness: {case_sensitive: false}
  validates :vin, uniqueness: {case_sensitive: false, allow_blank: true}
  validates :year, numericality: {only_integer: true, greater_than: 1900,
                                    less_than_or_equal_to: ->(_t) { Time.zone.today.year + 1 }},
                   allow_nil: true
end
