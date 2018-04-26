require 'rails_helper'

describe CollaboratorChecklistItem do

  it 'has valid factory' do
    expect(create(:collaborator_checklist_item)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of mandatory items, allows nil for non-mandatory items' do
      expect(build(:collaborator_checklist_item, list: nil)).to_not be_valid
      expect(build(:collaborator_checklist_item, project_checklist_item: nil)).to_not be_valid
      expect(build(:collaborator_checklist_item, checked: nil)).to be_valid
    end
  end
  
end