# frozen_string_literal: true

module Documents
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(document)
      @document = document
    end

    def call
      @document.discard!
      Result.new(success: true, message: "Document has been successfully deleted.")
    end
  end
end
