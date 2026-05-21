# frozen_string_literal: true

require "rails_helper"

RSpec.describe Discardable do
  it "is a Module" do
    expect(described_class).to be_a(Module)
  end

  it "depends on the discard gem" do
    expect(defined?(Discard::Model)).to eq("constant")
  end

  it "defines the discarded_by stamping callback method" do
    expect(described_class.private_instance_methods).to include(:stamp_discarded_by)
  end
end
