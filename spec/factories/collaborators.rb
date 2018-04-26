FactoryGirl.define do
  factory :collaborator do
    project
    user

    factory :lead_collaborator do
      lead true
    end
  end
end
