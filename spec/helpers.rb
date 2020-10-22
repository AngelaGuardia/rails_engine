module Helpers
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
