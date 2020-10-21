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

    it "#multi_finder" do
      merchant1 = Merchant.create(name: "King's shopper")
      merchant2 = Merchant.create(name: "Quiosquito de kingsito")
      merchant3 = Merchant.create(name: "Queen's shopper")
      merchant4 = Merchant.create(name: "Queen B's")
      merchant5 = Merchant.create(name: "La Queen")

      result = Merchant.multi_finder({name: 'Quiosquito'})
      expect(result.first).to eq(merchant2)

      result = Merchant.multi_finder({name: 'Queen'})
      expect(result.size).to eq(3)
      result.each do |merchant|
        expect([merchant3, merchant4, merchant5].include? Merchant.find(merchant[:id])).to be_truthy
      end

      result = Merchant.multi_finder({name: 'king'})
      expect(result.count).to eq(2)
      result.each do |merchant|
        expect([merchant1, merchant2].include? Merchant.find(merchant[:id])).to be_truthy
      end
    end
  end
end
