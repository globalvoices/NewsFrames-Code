FactoryGirl.define do
  factory :project_checklist do
    name { Faker::Lorem.characters(Faker::Number.between(1, 10)) }
    project
    checklist
  end
end
