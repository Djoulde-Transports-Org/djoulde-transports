# frozen_string_literal: true

# Audited stores `audited_changes` as TEXT (MySQL). With Rails 7.1+, audited
# delegates serialization to `ActiveRecord::Coders::YAMLColumn`, which calls
# `Psych.safe_dump` with `ActiveRecord.yaml_column_permitted_classes`.
# The defaults reject Date / TimeWithZone / BigDecimal, so register the value
# types we persist on audited models.
Rails.application.config.active_record.yaml_column_permitted_classes ||= []
Rails.application.config.active_record.yaml_column_permitted_classes |= [
  Symbol,
  Date,
  DateTime,
  Time,
  ActiveSupport::TimeWithZone,
  ActiveSupport::TimeZone,
  BigDecimal,
]

# Audited::Audit ships from the gem and does not inherit ApplicationRecord, so
# it lacks the Ransack allowlist that the rest of our models get for free. The
# Active Admin read-only audit index needs to sort/filter on these columns.
#
# Explicitly require the audit model so the constant is guaranteed to be defined
# regardless of whether ActiveAdmin has already loaded its resources (e.g. during
# db:prepare the routes are not processed, so Audited::Audit would otherwise be
# uninitialized when after_initialize fires).
Rails.application.config.after_initialize do
  require "audited/audit"

  # audited 5.8.0 defines belongs_to :user and :associated without optional: true.
  # Rails 6+ makes belongs_to required by default, so presence validators are added
  # automatically. When no current user exists (tests, background jobs) the audit
  # record fails validation, causing update_attribute (used by discard 2.0) to roll
  # back and return false, making every discard! raise "A discarded record cannot
  # be discarded". Remove only the presence validators for these two optional
  # associations; :auditable intentionally stays required.
  Audited::Audit._validators.delete(:user)
  Audited::Audit._validators.delete(:associated)
  to_remove = Audited::Audit._validate_callbacks.select do |c|
    c.filter.is_a?(ActiveRecord::Validations::PresenceValidator) &&
      (c.filter.attributes & %i(user associated)).any?
  end
  to_remove.each { |c| Audited::Audit._validate_callbacks.delete(c) }

  Audited::Audit.singleton_class.class_eval do
    def ransackable_attributes(_auth_object = nil)
      %w(id action auditable_type auditable_id associated_type associated_id
         user_id user_type username version comment remote_address created_at)
    end

    def ransackable_associations(_auth_object = nil)
      %w(auditable user associated)
    end
  end
end
