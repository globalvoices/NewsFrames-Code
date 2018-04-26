require 'rails_helper'

describe CollaboratorChecklists do
  describe described_class::Create do
    let!(:project) { create(:project) }
    let!(:other_project) { create(:project) }
    
    let!(:checklist) { create(:checklist) }
    let!(:checklist_item_1) { create(:checklist_item, checklist: checklist) }
    let!(:checklist_item_2) { create(:checklist_item, checklist: checklist) }

    project_checklist = nil

    before do
      ProjectChecklists::Associate.(project: project, checklists: [checklist])
      project_checklist = project.checklists.last
    end

    let(:collaborator) { create(:collaborator, project: project) }
    let(:other_collaborator) { create(:collaborator, project: other_project) }

    it 'raises error if required parameters are not provided' do
      expect { described_class.(collaborator: nil, checklist: project_checklist) }.to raise_error ArgumentError
      expect { described_class.(collaborator: collaborator, checklist: nil) }.to raise_error ArgumentError
      expect { described_class.(collaborator: collaborator, checklist: project_checklist) }.not_to raise_error
    end

    it 'raises error if there is a project mismatch' do
      expect { described_class.(collaborator: other_collaborator, checklist: project_checklist) }.to raise_error StandardError
    end

    it 'creates collaborator checklist' do
      expect { described_class.(collaborator: collaborator, checklist: project_checklist) }.to change { CollaboratorChecklist.count }.by 1
    end

    it 'creates collaborator checklist items' do
      expect { described_class.(collaborator: collaborator, checklist: project_checklist) }.to change { CollaboratorChecklistItem.count }.by 2
    end
  end

  describe described_class::Destroy do
    let!(:project) { create(:project) }

    let!(:checklist) { create(:checklist) }
    let!(:checklist_item_1) { create(:checklist_item, checklist: checklist) }
    let!(:checklist_item_2) { create(:checklist_item, checklist: checklist) }

    collaborator = nil
    project_checklist = nil
    collaborator_checklist = nil

    before do
      ProjectChecklists::Associate.(project: project, checklists: [checklist])
      project_checklist = project.checklists.last

      collaborator = create(:collaborator, project: project)
      CollaboratorChecklists::Create.(collaborator: collaborator, checklist: project_checklist)
      collaborator_checklist = collaborator.checklists.last
    end

    it 'raises error if required parameters are not provided' do
      expect { described_class.(checklist: nil) }.to raise_error ArgumentError
      expect { described_class.(checklist: collaborator_checklist) }.not_to raise_error
    end

    it 'destroys collaborator checklist' do
      expect { described_class.(checklist: collaborator_checklist) }.to change { CollaboratorChecklist.count }.by -1
    end

    it 'destroys collaborator checklist' do
      expect { described_class.(checklist: collaborator_checklist) }.to change { CollaboratorChecklistItem.count }.by -2
    end
  end

  describe described_class::CheckItems do
    let!(:project) { create(:project) }
    let!(:other_project) { create(:project) }
    
    let!(:checklist) { create(:checklist) }
    let!(:checklist_item_1) { create(:checklist_item, checklist: checklist) }
    let!(:checklist_item_2) { create(:checklist_item, checklist: checklist) }

    project_checklist = nil
    other_project_checklist = nil
    collaborator_checklist = nil
    other_collaborator_checklist = nil
    collaborator = nil
    other_collaborator = nil

    before do
      ProjectChecklists::Associate.(project: project, checklists: [checklist])
      project_checklist = project.checklists.last

      collaborator = create(:collaborator, project: project)

      CollaboratorChecklists::Create.(collaborator: collaborator, checklist: project_checklist)
      collaborator_checklist = collaborator.checklists.last

      ProjectChecklists::Associate.(project: other_project, checklists: [checklist])
      other_project_checklist = other_project.checklists.last

      other_collaborator = create(:collaborator, project: other_project)

      CollaboratorChecklists::Create.(collaborator: other_collaborator, checklist: other_project_checklist)
      other_collaborator_checklist = other_collaborator.checklists.last
    end

    it 'raises error if required parameters are not provided' do
      expect { described_class.(collaborator: nil) }.to raise_error ArgumentError
      expect { described_class.(collaborator: create(:collaborator)) }.not_to raise_error
    end

    it 'raises error if invalid checklist item is passed' do
      expect { described_class.(collaborator: collaborator, checklist_items: [collaborator_checklist.items.first, other_collaborator_checklist.items.first]) }.to raise_error ArgumentError
    end

    it 'marks the specified item as checked' do
      expect(collaborator_checklist.items.first.checked).to eq false
      expect(collaborator_checklist.items.last.checked).to eq false

      described_class.(collaborator: collaborator, checklist_items: [collaborator_checklist.items.first])
      collaborator_checklist.reload

      expect(collaborator_checklist.items.first.checked).to eq true
      expect(collaborator_checklist.items.last.checked).to eq false
    end

    it 'markes the items not passed as unchecked' do
      described_class.(collaborator: collaborator, checklist_items: [collaborator_checklist.items.first])
      collaborator_checklist.reload

      expect(collaborator_checklist.items.first.checked).to eq true
      expect(collaborator_checklist.items.last.checked).to eq false

      described_class.(collaborator: collaborator, checklist_items: [collaborator_checklist.items.last])
      collaborator_checklist.reload

      expect(collaborator_checklist.items.first.checked).to eq false
      expect(collaborator_checklist.items.last.checked).to eq true
    end
  end
end