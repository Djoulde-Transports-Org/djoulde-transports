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
# Active Admin (ticket 12) read-only audit index needs to sort/filter on these.
#
# We hook the same `on_load(:active_record)` channel audited uses to require
# its model, so this runs *after* the model is already defined with its
# intended optional `belongs_to`s. Force-requiring "audited/audit" from a late
# initializer instead would reload it while `belongs_to_required_by_default` is
# on, adding spurious presence validators that break every audited write.
ActiveSupport.on_load(:active_record) do
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

# Audited::Audit ships from the gem and does not inherit ApplicationRecord, so
# it lacks the Ransack allowlist that the rest of our models get for free. The
# Active Admin (ticket 12) read-only audit index needs to sort/filter on these.
