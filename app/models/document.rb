# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
# Database name: primary
#
#  id                :bigint           not null, primary key
#  discarded_at      :datetime
#  doc_type          :integer          default("other"), not null
#  documentable_type :string(255)      not null
#  expires_on        :date
#  issued_on         :date
#  title             :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  discarded_by_id   :bigint
#  documentable_id   :bigint           not null
#  uploaded_by_id    :bigint
#
# Indexes
#
#  index_documents_on_discarded_at     (discarded_at)
#  index_documents_on_discarded_by_id  (discarded_by_id)
#  index_documents_on_documentable     (documentable_type,documentable_id)
#  index_documents_on_expires_on       (expires_on)
#  index_documents_on_uploaded_by_id   (uploaded_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (uploaded_by_id => users.id)
#
class Document < ApplicationRecord
  include Discardable
  audited

  enum :doc_type, {
    other: 0,
    insurance: 1,
    registration: 2,
    license: 3,
    inspection: 4,
    invoice: 5,
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
