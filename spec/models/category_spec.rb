require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:category) { create(:category)}
  
  describe 'associations' do
    it { should have_many(:products) }
  end

  describe "Validations" do
    it "is valid with valid attributes" do
      expect(category).to be_valid
    end

    it "is invalid without a title" do
      category.title = nil
      expect(category).to_not be_valid
    end
  end
end
