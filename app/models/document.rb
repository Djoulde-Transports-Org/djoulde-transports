class Document < ApplicationRecord
  include Discardable
  audited

  enum :doc_type, {
    other: 0,
    insurance: 1,
    registration: 2,
    license: 3,
    inspection: 4,
    invoice: 5
  }, default: :other

  belongs_to :documentable, polymorphic: true
  belongs_to :uploaded_by,  class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  has_one_attached :file

  validates :title, presence: true
  validate  :expiry_after_issue

  private

  def expiry_after_issue
    return if issued_on.blank? || expires_on.blank?
    return if expires_on >= issued_on

    errors.add(:expires_on, "must be on or after issued_on")
  end
end
