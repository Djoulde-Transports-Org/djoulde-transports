# frozen_string_literal: true

module DeliveryNotes
  class Discard < ApplicationService
    def initialize(delivery_note)
      @delivery_note = delivery_note
    end

    def call
      @delivery_note.discard!
      @delivery_note
    end
  end
end
