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
      expect(result).to eq(merchant1)

      result = Merchant.single_finder({name: 'kInG'})
      expect(result).to eq(merchant1)

      result = Merchant.single_finder({name: 'queen'})
      expect(result).to eq(merchant2)

      result = Merchant.single_finder({name: 'shopper'})
      expect(result).to be_a(Merchant)
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

    it "#most_revenue" do
      merchant1 = create(:merchant)
      item1 = create(:item, merchant: merchant1)
      invoice1 = create(:invoice, merchant: merchant1)
      create(:invoice_item, item: item1, quantity: 1, unit_price: 1.0, invoice: invoice1)
      transaction1 = create(:transaction, invoice: invoice1)

      merchant2 = create(:merchant)
      item2 = create(:item, merchant: merchant2)
      invoice2 = create(:invoice, merchant: merchant2)
      create(:invoice_item, item: item2, quantity: 2, unit_price: 2.0, invoice: invoice2)
      transaction2 = create(:transaction, invoice: invoice2)

      merchant3 = create(:merchant)
      item3 = create(:item, merchant: merchant3)
      invoice3 = create(:invoice, merchant: merchant3)
      invoice_item3 = create(:invoice_item, item: item3, quantity: 3, unit_price: 3.0, invoice: invoice3)
      transaction3 = create(:transaction, invoice: invoice3)

      result = Merchant.most_revenue({ quantity: 3 })
      expect(result[0]).to eq(merchant3)
      expect(result[1]).to eq(merchant2)
      expect(result[2]).to eq(merchant1)

      # does not include failed transactions
      transaction3.update(result: "failed")

      result = Merchant.most_revenue({ quantity: 3 })
      expect(result[0]).not_to eq(merchant3)
      expect(result[0]).to eq(merchant2)

      # does not include packaged invoices
      invoice2.update(status: 'packaged')

      result = Merchant.most_revenue({ quantity: 3 })
      expect(result[0]).not_to eq(merchant2)
      expect(result[0]).to eq(merchant1)
    end

    it "#most_items" do
      merchant1 = create(:merchant)
      item1 = create(:item, merchant: merchant1)
      invoice1 = create(:invoice, merchant: merchant1)
      create(:invoice_item, item: item1, quantity: 1, unit_price: 1.0, invoice: invoice1)
      transaction1 = create(:transaction, invoice: invoice1)

      merchant2 = create(:merchant)
      item2 = create(:item, merchant: merchant2)
      invoice2 = create(:invoice, merchant: merchant2)
      create(:invoice_item, item: item2, quantity: 2, unit_price: 2.0, invoice: invoice2)
      transaction2 = create(:transaction, invoice: invoice2)

      merchant3 = create(:merchant)
      item3 = create(:item, merchant: merchant3)
      invoice3 = create(:invoice, merchant: merchant3)
      invoice_item3 = create(:invoice_item, item: item3, quantity: 3, unit_price: 3.0, invoice: invoice3)
      transaction3 = create(:transaction, invoice: invoice3)

      result = Merchant.most_items({ quantity: 3 })
      expect(result[0]).to eq(merchant3)
      expect(result[1]).to eq(merchant2)
      expect(result[2]).to eq(merchant1)

      # does not include failed transactions
      transaction3.update(result: "failed")

      result = Merchant.most_items({ quantity: 3 })
      expect(result[0]).not_to eq(merchant3)
      expect(result[0]).to eq(merchant2)

      # does not include packaged invoices
      invoice2.update(status: 'packaged')

      result = Merchant.most_items({ quantity: 3 })
      expect(result[0]).not_to eq(merchant2)
      expect(result[0]).to eq(merchant1)
    end
  end
end
