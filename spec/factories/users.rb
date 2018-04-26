FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password 'Test1234'
    approved true
    sequence(:author_id) { |n| "author-#{n}" }

    factory :admin do
      after(:create) { |user| user.add_role :admin }
    end

    factory :steward do
      after(:create) { |user| user.add_role :steward }
    end
  end
end
