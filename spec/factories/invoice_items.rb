FactoryBot.define do
  factory :invoice_item do
    item
    invoice
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { Faker::Number.decimal(l_digits: 2) }
  end
end
