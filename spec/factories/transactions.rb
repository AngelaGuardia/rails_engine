FactoryBot.define do
  factory :transaction do
    invoice
    credit_card_number { Faker::Stripe.valid_card }
    credit_card_expiration_date { "" }
    result { "success" }
  end
end
