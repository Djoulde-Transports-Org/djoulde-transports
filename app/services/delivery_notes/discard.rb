# frozen_string_literal: true

module DeliveryNotes
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(delivery_note)
      @delivery_note = delivery_note
    end

    def call
      @delivery_note.discard!
      Result.new(success: true, message: "Delivery note has been successfully deleted.")
    end
  end
end
