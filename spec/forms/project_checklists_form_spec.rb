require 'rails_helper'

describe ProjectChecklistsForm do
  it 'has valid factory' do
    expect(create(:project_checklists_form)).to be_valid
  end  

  it 'validates the presence of mandatory items' do
    expect(build(:project_checklists_form, user: nil)).to_not be_valid
    expect(build(:project_checklists_form, collaborator: nil)).to_not be_valid
  end

  describe '#initialize' do
    let(:project) { create(:project) }
    let(:collaborator) { create(:collaborator, project: project) }
    
    let!(:project_checklist_1) { create(:project_checklist, project: project) }
    let!(:project_checklist_2) { create(:project_checklist, project: project) }

    let!(:checklist_1) { create(:collaborator_checklist, collaborator: collaborator, project_checklist: project_checklist_1) }
    let!(:checklist_2) { create(:collaborator_checklist, collaborator: collaborator, project_checklist: project_checklist_2) }

    let!(:checklist_item_1) { create(:collaborator_checklist_item, collaborator_checklist: checklist_1) }
    let!(:checklist_item_2) { create(:collaborator_checklist_item, collaborator_checklist: checklist_2) }

    it 'initializes internal checklist variable' do
      form = ProjectChecklistsForm.new(collaborator: collaborator)
      expect(form.send(:checklists).length).to eq 2
      expect(form.send(:selected_checklist_items).length).to eq 0

      checklist_item_1.check! 
      
      collaborator.reload
      form = ProjectChecklistsForm.new(collaborator: collaborator)
      
      expect(form.send(:checklists).length).to eq 2
      expect(form.send(:selected_checklist_items).length).to eq 1
      expect(form.send(:selected_checklist_items)[0]).to eq checklist_item_1.id

      form = ProjectChecklistsForm.new(collaborator: collaborator, selected_checklist_items: ['', checklist_item_2.id.to_s])
      expect(form.send(:checklists).length).to eq 2
      expect(form.send(:selected_checklist_items).length).to eq 1
      expect(form.send(:selected_checklist_items)[0]).to eq checklist_item_2.id
    end
  end

  describe '#save!' do
    let!(:checklist_item_1) { create(:collaborator_checklist_item) }

    it 'calls collaborator checklist items service' do
      checklist_item_1.check! 
      form = ProjectChecklistsForm.new(collaborator: checklist_item_1.checklist.collaborator, user: create(:user))
      expect(CollaboratorChecklists::CheckItems).to receive(:call) do |params|
        expect(params[:collaborator]).to eq form.collaborator
        expect(params[:checklist_items]).to eq [checklist_item_1]
      end
      form.save!
    end
  end

end