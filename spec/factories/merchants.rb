FactoryBot.define do
  factory :merchant do
    name { Faker::TvShows::SiliconValley.company }
  end
end
