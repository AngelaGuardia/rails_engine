require 'rails_helper'

describe "Merchants API" do
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
    serializer_structure_check(merchant)

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
    serializer_structure_check(merchant)

    expect(merchant[:attributes][:id]).to eq(merchant_object.id)
  end

  it "can create a new merchant" do
    merchant_params = { name: "walmart" }

    headers = {"CONTENT_TYPE" => "application/json"}

    post '/api/v1/merchants', headers: headers, params: JSON.generate(merchant: merchant_params)

    expect(response).to be_successful
    merchants_data = JSON.parse(response.body, symbolize_names: true)

    expect(merchants_data).to have_key(:data)
    expect(merchants_data[:data]).to be_an(Hash)

    merchant = merchants_data[:data]
    serializer_structure_check(merchant)

    merchant_object = Merchant.last

    expect(merchant_object.name).to eq(merchant_params[:name])
  end

  it "can update an existing merchant" do
    id = create(:merchant).id
    previous_name = Merchant.last.name
    merchant_params = { name: "Sam's Club" }

    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})

    merchants_data = JSON.parse(response.body, symbolize_names: true)

    expect(merchants_data).to have_key(:data)
    expect(merchants_data[:data]).to be_an(Hash)

    merchant = merchants_data[:data]
    serializer_structure_check(merchant)

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

    merchants_data = JSON.parse(response.body, symbolize_names: true)

    expect(merchants_data).to have_key(:data)
    expect(merchants_data[:data]).to be_an(Hash)

    merchant = merchants_data[:data]
    serializer_structure_check(merchant)
  end

  def serializer_structure_check(merchant)
    expect(merchant).to have_key(:id)
    expect(merchant[:id]).to be_a(String)

    expect(merchant).to have_key(:type)
    expect(merchant[:type]).to be_a(String)
    expect(merchant[:type]).to eq("merchant")

    expect(merchant).to have_key(:attributes)
    expect(merchant[:attributes]).to be_a(Hash)

    expect(merchant[:attributes]).to have_key(:name)
    expect(merchant[:attributes][:name]).to be_a(String)

    expect(merchant[:attributes]).to have_key(:id)
    expect(merchant[:attributes][:id]).to be_an(Integer)

    expect(merchant).to have_key(:relationships)
    expect(merchant[:relationships]).to be_a(Hash)
    expect(merchant[:relationships]).to have_key(:items)
    expect(merchant[:relationships][:items]).to be_a(Hash)
    expect(merchant[:relationships]).to have_key(:invoices)
    expect(merchant[:relationships][:invoices]).to be_a(Hash)
  end
end
