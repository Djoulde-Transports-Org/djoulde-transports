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
  BigDecimal
]
