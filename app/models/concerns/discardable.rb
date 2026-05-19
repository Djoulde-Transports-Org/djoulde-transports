module Discardable
  extend ActiveSupport::Concern

  included do
    include Discard::Model

    before_discard :stamp_discarded_by
  end

  private

  def stamp_discarded_by
    return unless respond_to?(:discarded_by_id=)

    self.discarded_by_id = Current.user&.id
  end
end
