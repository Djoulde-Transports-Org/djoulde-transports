# frozen_string_literal: true

RSpec.describe API::V1::Entities::DeleteResult do
  let(:result)  { Trucks::Discard::Result.new(success: true, message: "Done.") }
  let(:payload) { described_class.represent(result).as_json }

  it "exposes success" do
    expect(payload[:success]).to be true
  end

  it "exposes the message" do
    expect(payload[:message]).to eq("Done.")
  end
end
