# frozen_string_literal: true

require "rails_helper"

RSpec.describe Documents::Discard do
  let(:truck)    { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:document) { Document.create!(documentable: truck, number: "INS-1", title: "Insurance") }

  it "discards the document" do
    described_class.call(document)
    expect(document.reload.discarded?).to be true
  end

  describe "the returned result" do
    let(:result) { described_class.call(document) }

    it "is a Documents::Discard::Result" do
      expect(result).to be_a(Documents::Discard::Result)
    end

    it "is successful" do
      expect(result.success).to be true
    end

    it "carries a success message" do
      expect(result.message).to eq("Document has been successfully deleted.")
    end
  end
end
