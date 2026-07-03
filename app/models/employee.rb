# frozen_string_literal: true

# == Schema Information
#
# Table name: employees
# Database name: primary
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  first_name      :string(255)      not null
#  last_name       :string(255)      not null
#  phone_number    :string(255)
#  role            :integer          default("driver"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :bigint
#  discarded_by_id :bigint
#  user_id         :bigint
#
# Indexes
#
#  index_employees_on_created_by_id    (created_by_id)
#  index_employees_on_discarded_at     (discarded_at)
#  index_employees_on_discarded_by_id  (discarded_by_id)
#  index_employees_on_role             (role)
#  index_employees_on_user_id          (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class Employee < ApplicationRecord
  include Discardable
  audited

  enum :role, {driver: 0, mechanic: 1, dispatcher: 2, manager: 3}, default: :driver

  belongs_to :user,         optional: true
  belongs_to :created_by,   class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  has_one  :truck,     foreign_key: :driver_id, dependent: :nullify, inverse_of: :driver
  has_many :trips,     foreign_key: :driver_id, dependent: :restrict_with_error, inverse_of: :driver
  has_many :documents, as: :documentable, dependent: :restrict_with_error

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :user_id,    uniqueness: {allow_nil: true}
end
