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
  end
end
