FactoryBot.define do
  factory :transaction do
    invoice { nil }
    credit_card_number { Faker::Stripe.valid_card }
    credit_card_expiration_date { "" }
    result { 0 }
  end
end
