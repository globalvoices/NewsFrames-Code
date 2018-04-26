require 'rails_helper'

describe ProjectChecklistItem do

  it 'has valid factory' do
    expect(create(:project_checklist_item)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of mandatory items, allows nil for non-mandatory items' do
      expect(build(:project_checklist_item, item: nil)).to_not be_valid
      expect(build(:project_checklist_item, list: nil)).to_not be_valid
      expect(build(:project_checklist_item, help: nil)).to be_valid
    end
  end
  
end