require 'rails_helper'

describe "Merchants API" do
  describe "Endpoints" do
    before :each do
      create_list(:merchant, 2)
      create_list(:item, 3, merchant_id: Merchant.first.id)
      create_list(:item, 3, merchant_id: Merchant.last.id)
      create_list(:customer, 2)
      create_list(:invoice, 3, merchant_id: Merchant.first.id, customer_id: Customer.first.id)
      create_list(:invoice, 3, merchant_id: Merchant.last.id, customer_id: Customer.last.id)
    end

    it "sends a list of merchants" do
      get '/api/v1/merchants'
      expect(response).to be_successful

      merchants_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Array)

      merchants = merchants_data[:data]
      merchant = merchants.first
      merchant_serializer_structure_check(merchant)

      expect(merchants.count).to eq(2)
    end

    it "can show a specific merchant by id" do
      merchant_object = Merchant.last

      get "/api/v1/merchants/#{merchant_object.id}"
      expect(response).to be_successful

      merchants_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Hash)

      merchant = merchants_data[:data]
      merchant_serializer_structure_check(merchant)

      expect(merchant[:attributes][:id]).to eq(merchant_object.id)
    end

    it "can create a new merchant" do
      merchant_params = { name: "walmart" }

      headers = {"CONTENT_TYPE" => "application/json"}

      post '/api/v1/merchants', headers: headers, params: JSON.generate(merchant_params)

      expect(response).to be_successful
      merchants_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Hash)

      merchant = merchants_data[:data]
      merchant_serializer_structure_check(merchant)

      merchant_object = Merchant.last

      expect(merchant_object.name).to eq(merchant_params[:name])
    end

    it "can update an existing merchant" do
      id = create(:merchant).id
      previous_name = Merchant.last.name
      merchant_params = { name: "Sam's Club" }

      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate(merchant_params)
      expect(response).to be_successful

      merchants_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Hash)

      merchant = merchants_data[:data]
      merchant_serializer_structure_check(merchant)

      merchant_object = Merchant.find_by(id: id)

      expect(response).to be_successful
      expect(merchant_object.name).to_not eq(previous_name)
      expect(merchant_object.name).to eq("Sam's Club")
    end

    it "can destroy a merchant" do
      merchant = Merchant.last
      expect(Merchant.count).to eq(2)

      delete "/api/v1/merchants/#{merchant.id}"

      expect(response).to be_successful

      expect(Merchant.count).to eq(1)
      expect{Merchant.find(merchant.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "relationships" do
    it "returns all items for one merchant" do
      merchantA = create(:merchant)
      merchantB = create(:merchant)

      itemA1 = create(:item, merchant_id: merchantA.id)
      itemB1 = create(:item, merchant_id: merchantB.id)
      itemB2 = create(:item, merchant_id: merchantB.id)

      get "/api/v1/merchants/#{merchantB.id}/items"
      expect(response).to be_successful

      items_data = JSON.parse(response.body, symbolize_names: true)

      expect(items_data).to have_key(:data)
      expect(items_data[:data]).to be_an(Array)
      expect(items_data[:data].size).to eq(2)
      expect(items_data[:data].first[:id]).to eq(itemB1.id.to_s)

      item_serializer_structure_check(items_data[:data].first)
    end
  end

  describe "Find Endpoints" do
    it "finds one merchant from case insensitive search" do
      merchant1 = Merchant.create(name: "King's shopper")
      merchant2 = Merchant.create(name: "Queen's shopper")

      # king search
      get "/api/v1/merchants/find", params: { name: "king" }
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data).to have_key(:data)
      expect(merchant_data[:data]).to be_an(Hash)
      merchant_serializer_structure_check(merchant_data[:data])

      result_merchant = Merchant.find(merchant_data[:data][:id])

      expect(result_merchant).to eq(merchant1)

      #QuEEn search
      get "/api/v1/merchants/find", params: { name: "QuEEn" }
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data).to have_key(:data)
      expect(merchant_data[:data]).to be_an(Hash)
      merchant_serializer_structure_check(merchant_data[:data])

      result_merchant = Merchant.find(merchant_data[:data][:id])

      expect(result_merchant).to eq(merchant2)

      # Mutiple hit search
      get "/api/v1/merchants/find", params: { name: "shopper" }
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data).to have_key(:data)
      expect(merchant_data[:data]).to be_an(Hash)
      merchant_serializer_structure_check(merchant_data[:data])
    end

    it "finds multiple merchants from case insensitive search" do
      merchant1 = Merchant.create(name: "King's shopper")
      merchant2 = Merchant.create(name: "Quiosquito de kingsito")
      merchant3 = Merchant.create(name: "Queen's shopper")
      merchant4 = Merchant.create(name: "Queen B's")
      merchant5 = Merchant.create(name: "La Queen")

      # search with one hit
      get "/api/v1/merchants/find_all", params: { name: "Quiosquito" }
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data).to have_key(:data)
      expect(merchant_data[:data]).to be_an(Array)
      merchant_serializer_structure_check(merchant_data[:data].first)

      result_merchant = Merchant.find(merchant_data[:data].first[:id])

      expect(result_merchant).to eq(merchant2)

      # multiple hit search
      get "/api/v1/merchants/find_all", params: { name: "Queen" }
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data).to have_key(:data)
      expect(merchant_data[:data]).to be_an(Array)
      merchant_serializer_structure_check(merchant_data[:data].first)

      expect(merchant_data[:data].count).to eq(3)

      merchant_data[:data].each do |merchant|
        expect([merchant3, merchant4, merchant5].include? Merchant.find(merchant[:id])).to be_truthy
      end

      # Mutiple hit search case insensitive
      get "/api/v1/merchants/find_all", params: { name: "king" }
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data).to have_key(:data)
      expect(merchant_data[:data]).to be_an(Array)
      merchant_serializer_structure_check(merchant_data[:data].first)

      expect(merchant_data[:data].size).to eq(2)
      merchant_data[:data].each do |merchant|
        expect([merchant1, merchant2].include? Merchant.find(merchant[:id])).to be_truthy
      end
    end
  end

  describe "business intelligence" do
    before :each do
      @merchant1 = create(:merchant)
      item1 = create(:item, merchant: @merchant1)
      invoice1 = create(:invoice, merchant: @merchant1, created_at: 2.days.ago)
      create(:invoice_item, item: item1, quantity: 1, unit_price: 1.0, invoice: invoice1)
      transaction1 = create(:transaction, invoice: invoice1)

      @merchant2 = create(:merchant)
      item2 = create(:item, merchant: @merchant2)
      invoice2 = create(:invoice, merchant: @merchant2, created_at: DateTime.now)
      create(:invoice_item, item: item2, quantity: 2, unit_price: 2.0, invoice: invoice2)
      transaction2 = create(:transaction, invoice: invoice2)

      @merchant3 = create(:merchant)
      item3 = create(:item, merchant: @merchant3)
      invoice3 = create(:invoice, merchant: @merchant3, created_at: DateTime.now + 2.days)
      create(:invoice_item, item: item3, quantity: 3, unit_price: 3.0, invoice: invoice3)
      transaction3 = create(:transaction, invoice: invoice3)
    end

    it "returns merchants with the most revenue" do
      get "/api/v1/merchants/most_revenue", params: { quantity: 3 }
      expect(response).to be_successful

      merchants_data = JSON.parse(response.body, symbolize_names: true)
      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Array)
      expect(merchants_data[:data].size).to eq(3)
      merchant_serializer_structure_check(merchants_data[:data].first)

      expect(merchants_data[:data][0][:id]).to eq(@merchant3.id.to_s)
      expect(merchants_data[:data][1][:id]).to eq(@merchant2.id.to_s)
      expect(merchants_data[:data][2][:id]).to eq(@merchant1.id.to_s)

      get "/api/v1/merchants/most_revenue", params: { quantity: 1 }
      expect(response).to be_successful

      merchants_data = JSON.parse(response.body, symbolize_names: true)
      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Array)
      expect(merchants_data[:data].size).to eq(1)
      merchant_serializer_structure_check(merchants_data[:data].first)

      expect(merchants_data[:data][0][:id]).to eq(@merchant3.id.to_s)

      get "/api/v1/merchants/most_revenue", params: { quantity: 0 }
      expect(response).to be_successful

      merchants_data = JSON.parse(response.body, symbolize_names: true)
      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Array)
      expect(merchants_data[:data].size).to eq(0)
    end

    it "returns merchant with most items sold" do
      get "/api/v1/merchants/most_items", params: { quantity: 3 }
      expect(response).to be_successful

      merchants_data = JSON.parse(response.body, symbolize_names: true)
      expect(merchants_data).to have_key(:data)
      expect(merchants_data[:data]).to be_an(Array)
      expect(merchants_data[:data].size).to eq(3)
      merchant_serializer_structure_check(merchants_data[:data].first)

      expect(merchants_data[:data][0][:id]).to eq(@merchant3.id.to_s)
      expect(merchants_data[:data][1][:id]).to eq(@merchant2.id.to_s)
      expect(merchants_data[:data][2][:id]).to eq(@merchant1.id.to_s)

      get "/api/v1/merchants/most_items", params: { quantity: 0 }
      expect(response).to be_successful
    end

    it "returns total revenue for all merchants over a date range" do
      get '/api/v1/revenue', params: { start: 3.days.ago.to_s, end: (Date.today + 3.days).to_s}
      expect(response).to be_successful

      revenue_data = JSON.parse(response.body, symbolize_names: true)
      expect(revenue_data).to have_key(:data)
      expect(revenue_data[:data]).to be_an(Hash)
      expect(revenue_data[:data]).to have_key(:id)
      expect(revenue_data[:data][:id]).to eq(nil)
      expect(revenue_data[:data]).to have_key(:attributes)
      expect(revenue_data[:data][:attributes]).to be_a(Hash)
      expect(revenue_data[:data][:attributes]).to have_key(:revenue)
      expect(revenue_data[:data][:attributes][:revenue]).to be_a(Float)
      expect(revenue_data[:data][:attributes][:revenue]).to eq(14)

      get '/api/v1/revenue', params: { start: 1.days.ago.to_s, end: (Date.today + 3.days).to_s}
      expect(response).to be_successful

      revenue_data = JSON.parse(response.body, symbolize_names: true)
      expect(revenue_data[:data][:attributes][:revenue]).to eq(13)

      get '/api/v1/revenue', params: { start: 2.days.ago.to_s, end: (Date.today + 1.days).to_s}
      expect(response).to be_successful

      revenue_data = JSON.parse(response.body, symbolize_names: true)
      expect(revenue_data[:data][:attributes][:revenue]).to eq(5)

      get '/api/v1/revenue', params: { start: (Date.today + 5.days).to_s, end: (Date.today + 10.days).to_s}
      expect(response).to be_successful

      revenue_data = JSON.parse(response.body, symbolize_names: true)
      expect(revenue_data[:data][:attributes][:revenue]).to eq(0)
    end

    it "returns revenue for a merchant" do
      get "/api/v1/merchants/#{@merchant1.id}/revenue"
      expect(response).to be_successful

      revenue_data = JSON.parse(response.body, symbolize_names: true)

      expect(revenue_data).to have_key(:data)
      expect(revenue_data[:data]).to be_an(Hash)
      expect(revenue_data[:data]).to have_key(:id)
      expect(revenue_data[:data][:id]).to eq(nil)
      expect(revenue_data[:data]).to have_key(:attributes)
      expect(revenue_data[:data][:attributes]).to be_a(Hash)
      expect(revenue_data[:data][:attributes]).to have_key(:revenue)
      expect(revenue_data[:data][:attributes][:revenue]).to be_a(Float)

      expect(revenue_data[:data][:attributes][:revenue]).to eq(1)
    end
  end
end
