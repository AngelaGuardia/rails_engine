FactoryBot.define do
  factory :invoice_item do
    item { nil }
    invoice { nil }
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { nil }
  end
end
