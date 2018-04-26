require 'rails_helper'

describe CollaboratorChecklist do

  it 'has valid factory' do
    expect(create(:collaborator_checklist)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of mandatory items, allows nil for non-mandatory items' do
      expect(build(:collaborator_checklist, collaborator: nil)).to_not be_valid
      expect(build(:collaborator_checklist, project_checklist: nil)).to be_valid
    end
  end

  it 'destroys items when checklist is deleted' do
    chklst = create(:collaborator_checklist)
    chklst_item_1 = create(:collaborator_checklist_item, list: chklst)
    chklst_item_2 = create(:collaborator_checklist_item, list: chklst)

    chklst_item_3 = create(:collaborator_checklist_item)
    
    chklst.destroy
    
    expect(chklst.destroyed?).to eq true
    expect { chklst_item_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { chklst_item_2.reload }.to raise_error(ActiveRecord::RecordNotFound)

    expect { chklst_item_3.reload }.to_not raise_error
  end

  it 'provides progress indicator' do
    chklst = create(:collaborator_checklist)

    expect(chklst.checked_count).to eq 0
    expect(chklst.progress).to eq 0
    
    chklst_item_1 = create(:collaborator_checklist_item, list: chklst, checked: true)
    chklst_item_2 = create(:collaborator_checklist_item, list: chklst, checked: false)
    chklst.reload

    expect(chklst.checked_count).to eq 1
    expect(chklst.progress).to eq 50

    chklst_item_2.check!
    chklst.reload

    expect(chklst.checked_count).to eq 2
    expect(chklst.progress).to eq 100
  end
  
end