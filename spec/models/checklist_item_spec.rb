require 'rails_helper'

describe ChecklistItem do

  it 'has valid factory' do
    expect(create(:checklist_item)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of mandatory items, allows nil for non-mandatory items' do
      expect(build(:checklist_item, item: nil)).to_not be_valid
      expect(build(:checklist_item, list: nil)).to_not be_valid
      expect(build(:checklist_item, help: nil)).to be_valid
    end

    it 'validates uniqueness of item within a list' do
      chklst_item = create(:checklist_item)
      
      expect(build(:checklist_item, list: chklst_item.list, item: chklst_item.item)).to_not be_valid
      expect(build(:checklist_item, list: chklst_item.list, item: chklst_item.item.upcase)).to_not be_valid
      expect(build(:checklist_item, list: chklst_item.list, item: chklst_item.item.downcase)).to_not be_valid

      expect(build(:checklist_item, item: chklst_item.item)).to be_valid
    end
  end
  
end