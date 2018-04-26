FactoryGirl.define do
  factory :checklist_item do
    item { Faker::Lorem.characters(Faker::Number.between(1, 10)) }
    help { Faker::Lorem.sentence(Faker::Number.between(1, 10)) }
    checklist
  end
end
