FactoryGirl.define do
  factory :collaborator_checklist_item do
    collaborator_checklist
    project_checklist_item
    checked false
  end
end
