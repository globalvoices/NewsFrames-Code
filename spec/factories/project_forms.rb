FactoryGirl.define do
  factory :project_form do
    project
    user
    name { Faker::Lorem.characters(Faker::Number.between(1, 10)) }
  end
end
