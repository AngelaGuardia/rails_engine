require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
    it { should validate_numericality_of(:unit_price).is_greater_than(0) }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:transactions).through(:invoices) }
  end

  describe 'class methods' do
    it '#single_finder' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = Item.create(name: "Golf club", description: "The most powerful club ever", unit_price: 109.89, merchant: merchant1)
      item2 = Item.create(name: "Club Soda", description: "Best drink you have ever tasted", unit_price: 50.89, merchant: merchant2)

      result = Item.single_finder({ name: 'Golf' })
      expect(result).to eq(item1)

      result = Item.single_finder({ name: 'club' })
      expect(result).to be_an(Item)

      result = Item.single_finder({ description: "drink" })
      expect(result).to eq(item2)

      result = Item.single_finder({ unit_price: 50.89 })
      expect(result).to eq(item2)

      result = Item.single_finder({ merchant_id: merchant1.id })
      expect(result).to eq(item1)

      # result = Item.single_finder({ created_at: DateTime.now })
      # expect(result).to be_an(Item)
      #
      # result = Item.single_finder({ updated_at: DateTime.now })
      # expect(result).to be_an(Item)
    end

    it '#multi_finder' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = Item.create(name: "Golf club", description: "The most powerful club ever", unit_price: 109.89, merchant: merchant1)
      item2 = Item.create(name: "Club Soda", description: "Best drink you have ever tasted", unit_price: 50.89, merchant: merchant2)
      item3 = Item.create(name: "Soda can", description: "It's a can", unit_price: 50.89, merchant: merchant2)
      item4 = Item.create(name: "Soda shop", description: "welcome to the soda shop", unit_price: 60, merchant: merchant2)

      result = Item.multi_finder({ name: 'Golf' })
      expect(result.first).to eq(item1)

      result = Item.multi_finder({ name: 'Soda' })
      result.each do |item|
        expect([item2, item3, item4].include? item).to be_truthy
      end

      result = Item.multi_finder({ name: 'club' })
      result.each do |item|
        expect([item1, item2].include? item).to be_truthy
      end

      result = Item.multi_finder({ description: 'ever' })
      result.each do |item|
        expect([item1, item2].include? item).to be_truthy
      end

      result = Item.multi_finder({ unit_price: 50.89 })
      result.each do |item|
        expect([item3, item2].include? item).to be_truthy
      end

      result = Item.multi_finder({ merchant_id: merchant2.id })
      result.each do |item|
        expect([item2, item3, item4].include? item).to be_truthy
      end

      #created_at
      #updated_at
    end
  end
end
