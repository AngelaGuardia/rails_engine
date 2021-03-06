require 'rails_helper'

describe "Items API" do
  describe "CRUD Endpoints" do
    it "sends a list of items" do
      merchant1 = create(:merchant)
      create_list(:item, 3, merchant_id: merchant1.id)

      get '/api/v1/items'
      expect(response).to be_successful

      items_data = JSON.parse(response.body, symbolize_names: true)

      expect(items_data).to have_key(:data)
      expect(items_data[:data]).to be_an(Array)

      items = items_data[:data]
      item_serializer_structure_check(items.first)

      expect(items.count).to eq(3)
    end

    it "can show a specific item by id" do
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id

      get "/api/v1/items/#{id}"
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)

      item = item_data[:data]
      item_serializer_structure_check(item)
    end

    it "can create a new item" do
      merchant = create(:merchant)
      item_params = {
                      name: "new item",
                      description: "this is a new item",
                      unit_price: 1.26,
                      merchant_id: merchant.id
      }

      headers = {"CONTENT_TYPE" => "application/json"}

      post '/api/v1/items', headers: headers, params: JSON.generate(item_params)

      expect(response).to be_successful
      item = Item.last

      expect(item.name).to eq(item_params[:name])
      expect(item.description).to eq(item_params[:description])
      expect(item.unit_price).to eq(item_params[:unit_price])

      item_data = JSON.parse(response.body, symbolize_names: true)
      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)

      item = item_data[:data]
      item_serializer_structure_check(item)
    end

    it "can update an item" do
      merchant = create(:merchant)
      item = create(:item, merchant_id: merchant.id)
      previous_name = item.name
      item_params = { name: "new name" }

      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item_params)

      expect(response).to be_successful
      item = Item.find_by(id: item.id)

      expect(item.name).not_to eq(previous_name)
      expect(item.name).to eq(item_params[:name])

      item_data = JSON.parse(response.body, symbolize_names: true)
      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)

      item = item_data[:data]
      item_serializer_structure_check(item)
    end

    it "can destroy an item" do
      merchant = create(:merchant)
      item = create(:item, merchant_id: merchant.id)

      expect(Item.count).to eq(1)

      delete "/api/v1/items/#{item.id}"

      expect(response).to be_successful
      expect(Item.count).to eq(0)
      expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "relationship Endpoints" do
    it "returns the merchant associated with an item" do
      merchant = create(:merchant)
      item = create(:item, merchant: merchant)

      get "/api/v1/items/#{item.id}/merchants"
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data).to have_key(:data)
      expect(merchant_data[:data]).to be_a(Hash)
      expect(merchant_data[:data][:id]).to eq(merchant.id.to_s)

      merchant_serializer_structure_check(merchant_data[:data])
    end
  end

  describe "Search Endpoints" do
    it "finds one item from case insensitive search" do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = Item.create(name: "Golf club", description: "The most powerful club ever", unit_price: 109.89, merchant: merchant1)
      item2 = Item.create(name: "Club Soda", description: "Best drink you have ever tasted", unit_price: 50.89, merchant: merchant2)

      # search by name

      # One hit search
      get "/api/v1/items/find", params: { name: "Golf" }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)
      item_serializer_structure_check(item_data[:data])

      result_item = Item.find(item_data[:data][:id])

      expect(result_item).to eq(item1)

      # Multiple hit search case insensitive returns one result
      get "/api/v1/items/find", params: { name: "club" }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)
      item_serializer_structure_check(item_data[:data])

      # search by description

      get "/api/v1/items/find", params: { description: "drink" }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)
      item_serializer_structure_check(item_data[:data])

      result_item = Item.find(item_data[:data][:id])

      expect(result_item).to eq(item2)

      # search by unit_price

      get "/api/v1/items/find", params: { unit_price: 50.89 }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)
      item_serializer_structure_check(item_data[:data])

      result_item = Item.find(item_data[:data][:id])

      expect(result_item).to eq(item2)

      # search by merchant_id

      get "/api/v1/items/find", params: { merchant_id: merchant1.id }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Hash)
      item_serializer_structure_check(item_data[:data])

      result_item = Item.find(item_data[:data][:id])

      expect(result_item).to eq(item1)

      # # search by created_at
      #
      # get "/api/v1/items/find", params: { created_at: Date.today }
      # expect(response).to be_successful
      #
      # item_data = JSON.parse(response.body, symbolize_names: true)
      #
      # expect(item_data).to have_key(:data)
      # expect(item_data[:data]).to be_an(Hash)
      # item_serializer_structure_check(item_data[:data])
      #
      # # search by updated_at
      #
      # get "/api/v1/items/find", params: { updated_at: Date.today }
      # expect(response).to be_successful
      #
      # item_data = JSON.parse(response.body, symbolize_names: true)
      #
      # expect(item_data).to have_key(:data)
      # expect(item_data[:data]).to be_an(Hash)
      # item_serializer_structure_check(item_data[:data])
    end

    it "finds multiple items from case insensitive search" do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = Item.create(name: "Golf club", description: "The most powerful club ever", unit_price: 109.89, merchant: merchant1)
      item2 = Item.create(name: "Club Soda", description: "Best drink you have ever tasted", unit_price: 50.89, merchant: merchant2)
      item3 = Item.create(name: "Soda can", description: "It's a can", unit_price: 50.89, merchant: merchant2)
      item4 = Item.create(name: "Soda shop", description: "welcome to the soda shop", unit_price: 60, merchant: merchant2)

      # search by name

      # One hit search
      get "/api/v1/items/find_all", params: { name: "Golf" }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Array)
      item_serializer_structure_check(item_data[:data].first)

      result_item = Item.find(item_data[:data].first[:id])

      expect(result_item).to eq(item1)

      # Multiple hit search
      get "/api/v1/items/find_all", params: { name: "Soda" }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Array)
      expect(item_data[:data].size).to eq(3)
      item_serializer_structure_check(item_data[:data].first)

      item_data[:data].each do |item|
        expect([item2, item3, item4].include? Item.find(item[:id])).to be_truthy
      end

      # Multiple hit search case insensitive returns one result
      get "/api/v1/items/find_all", params: { name: "club" }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Array)
      expect(item_data[:data].size).to eq(2)
      item_serializer_structure_check(item_data[:data].first)

      item_data[:data].each do |item|
        expect([item1, item2].include? Item.find(item[:id])).to be_truthy
      end

      # search by description

      get "/api/v1/items/find_all", params: { description: "ever" }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Array)
      expect(item_data[:data].size).to eq(2)
      item_serializer_structure_check(item_data[:data].first)

      item_data[:data].each do |item|
        expect([item1, item2].include? Item.find(item[:id])).to be_truthy
      end

      # search by unit_price

      get "/api/v1/items/find_all", params: { unit_price: 50.89 }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Array)
      expect(item_data[:data].size).to eq(2)
      item_serializer_structure_check(item_data[:data].first)

      item_data[:data].each do |item|
        expect([item3, item2].include? Item.find(item[:id])).to be_truthy
      end

      # search by merchant_id

      get "/api/v1/items/find_all", params: { merchant_id: merchant2.id }
      expect(response).to be_successful

      item_data = JSON.parse(response.body, symbolize_names: true)

      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_an(Array)
      expect(item_data[:data].size).to eq(3)
      item_serializer_structure_check(item_data[:data].first)

      item_data[:data].each do |item|
        expect([item2, item3, item4].include? Item.find(item[:id])).to be_truthy
      end

      # created_at test
      # updated_at test
    end
  end
end
