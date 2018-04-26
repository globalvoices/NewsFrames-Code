FactoryGirl.define do
  factory :checklist do
    sequence(:name) { |n| Faker::Lorem.characters(Faker::Number.between(1, 10)) + " #{n}" }
  end
end
