# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Ransack (a transitive Active Admin dependency, ticket 12) refuses to search
  # or sort any attribute/association that is not explicitly allowlisted. The
  # admin UI is the only Ransack consumer and is restricted to super_admins;
  # the public API is built on Grape and never touches Ransack. So we allow all
  # real columns and associations by default. Override in a model to narrow it.
  def self.ransackable_attributes(_auth_object = nil)
    column_names + _ransackers.keys
  end

  def self.ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |association| association.name.to_s }
  end
end
