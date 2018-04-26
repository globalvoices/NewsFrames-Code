require 'rails_helper'

describe Checklist do

  it 'has valid factory' do
    expect(create(:checklist)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of mandatory items, allows nil for non-mandatory items' do
      expect(build(:checklist, name: nil)).to_not be_valid
    end

    it 'validates uniqueness of name' do
      chklst = create(:checklist)
      expect(build(:checklist, name: chklst.name)).to_not be_valid
      expect(build(:checklist, name: chklst.name.upcase)).to_not be_valid
      expect(build(:checklist, name: chklst.name.downcase)).to_not be_valid
    end
  end

  it 'destroys items when checklist is deleted' do
    chklst = create(:checklist)
    chklst_item_1 = create(:checklist_item, list: chklst)
    chklst_item_2 = create(:checklist_item, list: chklst)

    chklst_item_3 = create(:checklist_item)
    
    chklst.destroy
    
    expect(chklst.destroyed?).to eq true
    expect { chklst_item_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { chklst_item_2.reload }.to raise_error(ActiveRecord::RecordNotFound)

    expect { chklst_item_3.reload }.to_not raise_error
  end

  it 'does not destroy project checklists when checklist is deleted' do
    chklst = create(:checklist)
    proj_chklst_1 = create(:project_checklist, checklist: chklst)
    proj_chklst_2 = create(:project_checklist)

    chklst.destroy

    expect(chklst.destroyed?).to eq true
    expect(proj_chklst_1.reload.checklist).to_not be
    expect(proj_chklst_2.reload.checklist).to be
  end
  
end