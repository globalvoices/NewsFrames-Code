require 'rails_helper'

describe ProjectChecklist do

  it 'has valid factory' do
    expect(create(:project_checklist)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of mandatory items, allows nil for non-mandatory items' do
      expect(build(:project_checklist, name: nil)).to_not be_valid
      expect(build(:project_checklist, project: nil)).to_not be_valid
      expect(build(:project_checklist, checklist: nil)).to be_valid
    end
  end

  describe '#destroy', current: true do
    let!(:project) { create(:project) }
    
    let!(:collaborator_1) { create(:collaborator, project: project) }   
    let!(:collaborator_2) { create(:collaborator, project: project) }

    let!(:project_checklist_1) { create(:project_checklist, project: project) }
    let!(:chklst_item_1) { create(:project_checklist_item, list: project_checklist_1) }
    let!(:chklst_item_2) { create(:project_checklist_item, list: project_checklist_1) }

    let!(:project_checklist_2) { create(:project_checklist, project: project) }
    let!(:chklst_item_3) { create(:project_checklist_item, list: project_checklist_2) }
    
    let!(:collaborator_checklist_1) { create(:collaborator_checklist, collaborator: collaborator_1, project_checklist: project_checklist_1) }
    let!(:collaborator_checklist_2) { create(:collaborator_checklist, collaborator: collaborator_1, project_checklist: project_checklist_2) }
    let!(:collaborator_checklist_3) { create(:collaborator_checklist, collaborator: collaborator_2, project_checklist: project_checklist_1) }

    it 'destroys items when checklist is deleted' do
      project_checklist_1.destroy
      
      expect(project_checklist_1.destroyed?).to eq true
      expect { chklst_item_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { chklst_item_2.reload }.to raise_error(ActiveRecord::RecordNotFound)

      expect { chklst_item_3.reload }.to_not raise_error
    end
    
    it 'deletes all collaborator checklists' do
      project_checklist_1.destroy

      expect(project_checklist_1.destroyed?).to eq true

      expect { collaborator_checklist_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { collaborator_checklist_3.reload }.to raise_error(ActiveRecord::RecordNotFound)
      
      expect { collaborator_checklist_2.reload }.to_not raise_error
    end
  end

  describe '#progress' do
    let!(:project) { create(:project) }
    
    let!(:collaborator_1) { create(:collaborator, project: project) }   
    let!(:collaborator_2) { create(:collaborator, project: project) }

    let!(:project_checklist) { create(:project_checklist, project: project) }
    let!(:chklst_item_1) { create(:project_checklist_item, list: project_checklist) }
    let!(:chklst_item_2) { create(:project_checklist_item, list: project_checklist) }
    
    let!(:collaborator_checklist_1) { create(:collaborator_checklist, collaborator: collaborator_1, project_checklist: project_checklist) }
    let!(:chklst_1_item_1) { create(:collaborator_checklist_item, collaborator_checklist: collaborator_checklist_1, project_checklist_item: chklst_item_1) }
    let!(:chklst_1_item_2) { create(:collaborator_checklist_item, collaborator_checklist: collaborator_checklist_1, project_checklist_item: chklst_item_2) }

    let!(:collaborator_checklist_2) { create(:collaborator_checklist, collaborator: collaborator_2, project_checklist: project_checklist) }
    let!(:chklst_2_item_1) { create(:collaborator_checklist_item, collaborator_checklist: collaborator_checklist_2, project_checklist_item: chklst_item_1) }
    let!(:chklst_2_item_2) { create(:collaborator_checklist_item, collaborator_checklist: collaborator_checklist_2, project_checklist_item: chklst_item_2) }
    
    it 'provides progress indicator' do
      expect(project_checklist.checked_count).to eq 0
      expect(project_checklist.progress).to eq 0
      
      chklst_1_item_1.check!
      chklst_1_item_2.check!

      project_checklist.reload

      expect(project_checklist.checked_count).to eq 2
      expect(project_checklist.progress).to eq 50

      chklst_2_item_1.check!
      chklst_2_item_2.check!

      project_checklist.reload

      expect(project_checklist.checked_count).to eq 4
      expect(project_checklist.progress).to eq 100
    end
  end

end