module Helpers
  def merchant_serializer_structure_check(merchant)
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

  def item_serializer_structure_check(item)
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
