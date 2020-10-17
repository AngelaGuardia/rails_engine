FactoryBot.define do
  factory :item do
    name { Faker::Games::Minecraft.item }
    description { Faker::JapaneseMedia::StudioGhibli.quote }
    price_unit { Faker::Number.decimal(l_digits: 2) }
    merchant { nil }
  end
end
