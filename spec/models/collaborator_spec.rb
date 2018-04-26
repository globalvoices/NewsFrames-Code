require 'rails_helper'

describe Collaborator do
  it 'has valid factory' do
    expect(create(:collaborator)).to be_valid
  end

  describe 'validations' do
    it 'validates presence of project' do
      expect(build(:collaborator, project: nil)).to_not be_valid
    end

    it 'validates presence of user' do
      expect(build(:collaborator, user: nil)).to_not be_valid
    end

    it 'validates uniqueness of user per project' do
      collaborator = create(:collaborator)
      expect(build(:collaborator, user: collaborator.user)).to be_valid
      expect(build(:collaborator, user: collaborator.user, project: collaborator.project)).to_not be_valid
    end

    it 'validates single project lead' do
      lead = create(:collaborator, lead: true)
      expect(build(:collaborator, project: lead.project)).to be_valid
      expect(build(:collaborator, project: lead.project, lead: true)).to_not be_valid
    end
  end

  describe '#destroy' do
    let!(:project) { create(:project) }
    
    let!(:collaborator_1) { create(:collaborator, project: project) }   
    let!(:collaborator_2) { create(:collaborator, project: project) }

    let!(:project_checklist_1) { create(:project_checklist, project: project) }
    let!(:project_checklist_2) { create(:project_checklist, project: project) }
    
    let!(:collaborator_checklist_1) { create(:collaborator_checklist, collaborator: collaborator_1, project_checklist: project_checklist_1) }
    let!(:collaborator_checklist_2) { create(:collaborator_checklist, collaborator: collaborator_1, project_checklist: project_checklist_2) }
    let!(:collaborator_checklist_3) { create(:collaborator_checklist, collaborator: collaborator_2, project_checklist: project_checklist_1) }
    
    it 'deletes all collaborator checklists' do
      expect(collaborator_1.checklists.count).to eq 2
      expect(collaborator_2.checklists.count).to eq 1

      collaborator_1.destroy

      expect { Collaborator.find(collaborator_1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { CollaboratorChecklist.find(collaborator_checklist_1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { CollaboratorChecklist.find(collaborator_checklist_2.id) }.to raise_error(ActiveRecord::RecordNotFound)
      
      expect { Collaborator.find(collaborator_2.id) }.to_not raise_error
      expect { CollaboratorChecklist.find(collaborator_checklist_3.id) }.to_not raise_error
    end
  end

  describe '#has_checklist?' do
    let!(:project) { create(:project) }
    
    let!(:collaborator_1) { create(:collaborator, project: project) }   
    let!(:collaborator_2) { create(:collaborator, project: project) }

    let!(:project_checklist_1) { create(:project_checklist, project: project) }
    let!(:project_checklist_2) { create(:project_checklist, project: project) }
    
    let!(:collaborator_checklist_1) { create(:collaborator_checklist, collaborator: collaborator_1, project_checklist: project_checklist_1) }
    let!(:collaborator_checklist_2) { create(:collaborator_checklist, collaborator: collaborator_1, project_checklist: project_checklist_2) }
    let!(:collaborator_checklist_3) { create(:collaborator_checklist, collaborator: collaborator_2, project_checklist: project_checklist_1) }
    
    it 'returns true if collaborator has specified checklist associated with it' do
      expect(collaborator_1.has_checklist?(project_checklist_1)).to eq true
      expect(collaborator_1.has_checklist?(project_checklist_2)).to eq true

      expect(collaborator_2.has_checklist?(project_checklist_1)).to eq true
      expect(collaborator_2.has_checklist?(project_checklist_2)).to eq false
    end
  end
end
