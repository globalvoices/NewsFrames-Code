FactoryGirl.define do
  factory :project do
    name { Faker::Team.name }

    after(:create) do |project|
      create(:project_pad, project: project, index: 0)
    end
  end
end
