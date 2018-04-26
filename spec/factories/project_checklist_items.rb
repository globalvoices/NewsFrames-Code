FactoryGirl.define do
  factory :project_checklist_item do
    item { Faker::Lorem.characters(Faker::Number.between(1, 10)) }
    help { Faker::Lorem.sentence(Faker::Number.between(1, 10)) }
    project_checklist
  end
end
