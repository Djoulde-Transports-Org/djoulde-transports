# frozen_string_literal: true

module Documents
  class Discard < ApplicationService
    def initialize(document)
      @document = document
    end

    def call
      @document.discard!
      @document
    end
  end
end
