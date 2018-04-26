FactoryGirl.define do
  factory :project_pad do
    project
    name { Faker::Lorem.word }
    sequence(:pad_id) { |n| "pad-#{n}" }
  end
end
