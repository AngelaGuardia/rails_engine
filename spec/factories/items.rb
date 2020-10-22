FactoryBot.define do
  factory :item do
    name { Faker::Games::Minecraft.item }
    description { Faker::TvShows::Community.quotes  }
    unit_price { Faker::Number.decimal(l_digits: 2) }
    merchant
  end
end
