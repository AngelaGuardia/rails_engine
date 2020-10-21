require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    merchant1 = create(:merchant)
    create_list(:item, 3, merchant_id: merchant1.id)

    get '/api/v1/items'
    expect(response).to be_successful

    items_data = JSON.parse(response.body, symbolize_names: true)

    expect(items_data).to have_key(:data)
    expect(items_data[:data]).to be_an(Array)

    items = items_data[:data]
    serializer_structure_check(items.first)

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
    serializer_structure_check(item)
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
    serializer_structure_check(item)
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
    serializer_structure_check(item)
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

  def serializer_structure_check(item)
    expect(item).to have_key(:id)
    expect(item[:id]).to be_an(String)

    expect(item).to have_key(:type)
    expect(item[:type]).to be_an(String)
    expect(item[:type]).to eq("item")

    expect(item).to have_key(:attributes)
    expect(item[:attributes]).to be_a(Hash)

    expect(item[:attributes]).to have_key(:id)
    expect(item[:attributes][:id]).to be_an(Integer)

    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes][:name]).to be_an(String)

    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes][:description]).to be_an(String)

    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes][:unit_price]).to be_an(Float)

    expect(item).to have_key(:relationships)
    expect(item[:relationships]).to be_a(Hash)

    expect(item[:relationships]).to have_key(:merchant)
    expect(item[:relationships][:merchant]).to be_a(Hash)

    expect(item[:relationships]).to have_key(:invoice_items)
    expect(item[:relationships][:invoice_items]).to be_a(Hash)

    expect(item[:relationships]).to have_key(:invoices)
    expect(item[:relationships][:invoices]).to be_a(Hash)

    expect(item[:relationships]).to have_key(:transactions)
    expect(item[:relationships][:transactions]).to be_a(Hash)
  end
end
