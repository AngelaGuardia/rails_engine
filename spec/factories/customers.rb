FactoryBot.define do
  factory :customer do
    name { Faker::TvShows::SiliconValley.character }
  end
end
