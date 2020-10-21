require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
  end

  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
  end

  describe 'class methods' do
    it '#single_finder' do
      merchant1 = Merchant.create(name: "King's shopper")
      merchant2 = Merchant.create(name: "Queen's shopper")

      result = Merchant.single_finder({name: 'King'})
      expect(result.first).to eq(merchant1)

      result = Merchant.single_finder({name: 'kInG'})
      expect(result.first).to eq(merchant1)

      result = Merchant.single_finder({name: 'queen'})
      expect(result.first).to eq(merchant2)

      result = Merchant.single_finder({name: 'shopper'})
      expect(result.count).to eq(1)
    end
  end
end
