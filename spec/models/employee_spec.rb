# frozen_string_literal: true

RSpec.describe Employee do
  let(:employee) { described_class.new(first_name: "Mamadou", last_name: "Diallo") }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  describe "validations" do
    it "is valid with first_name and last_name" do
      expect(employee).to be_valid
    end

    it "requires first_name" do
      employee.first_name = nil
      employee.validate
      expect(employee.errors[:first_name]).to be_present
    end

    it "requires last_name" do
      employee.last_name = nil
      employee.validate
      expect(employee.errors[:last_name]).to be_present
    end

    it "enforces user_id uniqueness" do
      user = User.create!(email: "u@example.com", password: "password123")
      described_class.create!(first_name: "Ibra", last_name: "Sow", user: user)
      duplicate = described_class.new(first_name: "Ali", last_name: "Bah", user: user)
      duplicate.validate
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "allows multiple employees without a user_id" do
      described_class.create!(first_name: "A", last_name: "A")
      second = described_class.new(first_name: "B", last_name: "B")
      expect(second).to be_valid
    end
  end

  describe "#full_name" do
    it "combines first_name and last_name" do
      expect(employee.full_name).to eq("Mamadou Diallo")
    end
  end

  describe "role enum" do
    it "defaults to driver" do
      employee.save!
      expect(employee.role).to eq("driver")
    end

    it "exposes all four roles" do
      expect(described_class.roles.keys)
        .to contain_exactly("driver", "mechanic", "dispatcher", "manager")
    end

    it "accepts mechanic" do
      employee.role = :mechanic
      expect(employee).to be_valid
    end
  end

  describe "associations" do
    it "belongs_to user (optional)", :aggregate_failures do
      reflection = described_class.reflect_on_association(:user)
      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:optional]).to be true
    end

    it "belongs_to created_by (User)" do
      reflection = described_class.reflect_on_association(:created_by)
      expect(reflection.options[:class_name]).to eq("User")
    end

    it "belongs_to discarded_by (User)" do
      reflection = described_class.reflect_on_association(:discarded_by)
      expect(reflection.options[:class_name]).to eq("User")
    end

    it "has_one :truck via driver_id", :aggregate_failures do
      reflection = described_class.reflect_on_association(:truck)
      expect(reflection.macro).to eq(:has_one)
      expect(reflection.options[:foreign_key]).to eq(:driver_id)
    end

    it "has_many :trips via driver_id", :aggregate_failures do
      reflection = described_class.reflect_on_association(:trips)
      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:foreign_key]).to eq(:driver_id)
    end

    it "has_many :documents as :documentable" do
      reflection = described_class.reflect_on_association(:documents)
      expect(reflection.options[:as]).to eq(:documentable)
    end
  end

  describe "discardable behaviour" do
    it "soft-deletes without removing the record" do
      employee.save!
      employee.discard
      expect(described_class.find(employee.id)).to be_discarded
    end

    it "stamps discarded_by from Current.user" do
      user = User.create!(email: "admin@example.com", password: "password123")
      Current.user = user
      employee.save!
      employee.discard
      expect(employee.reload.discarded_by_id).to eq(user.id)
    end
  end
end
