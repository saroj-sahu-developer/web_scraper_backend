require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product) { create(:product)}

  describe "Validations" do
    it "is valid with valid attributes" do
      expect(product).to be_valid
    end

    it "is invalid without a title" do
      product.title = nil
      expect(product).to_not be_valid
    end

    it "is invalid without a price" do
      product.price = nil
      expect(product).to_not be_valid
    end
  end

  describe "Associations" do
    it { should belong_to(:category).optional }
  end
end
