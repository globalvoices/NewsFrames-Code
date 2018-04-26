require 'rails_helper'

describe Project do
  it 'has valid factory' do
    expect(create(:project)).to be_valid
  end

  describe 'validations' do
    it 'validates presence of name' do
      expect(build(:project, name: nil)).to_not be_valid
    end
  end

  describe '#collaborators' do
    let(:project) { create(:project) }
    let!(:collaborators) { create_list(:collaborator, 3, project: project) }

    it { expect(project.collaborators).to eq collaborators }
  end

  describe '#users' do
    let(:project) { create(:project) }
    let!(:collaborators) { create_list(:collaborator, 3, project: project) }

    it { expect(project.users.count).to eq 3 }
    it { expect(project.users).to include collaborators[0].user }
    it { expect(project.users).to include collaborators[1].user }
    it { expect(project.users).to include collaborators[2].user }
  end

  describe '#lead' do
    let!(:project) { create(:project) }
    let!(:lead) { create(:collaborator, project: project, lead: true) }
    let!(:collaborator) { create(:collaborator, project: project) }

    it 'returns lead user' do
      expect(project.lead).to eq lead.user
    end
  end

  describe '#progress' do
    it 'provides progress indicator' do
      project = create(:project)
      
      expect(project.progress).to eq 0

      chklst_1 = create(:project_checklist, project: project)
      chklst_2 = create(:project_checklist, project: project)
      project.reload

      expect(project.progress).to eq 0

      chklst_item_1 = create(:project_checklist_item, list: chklst_1)
      chklst_item_2 = create(:project_checklist_item, list: chklst_1)
      chklst_item_3 = create(:project_checklist_item, list: chklst_2)

      collaborator = create(:collaborator, project: project)

      collaborator_chklst_1 = create(:collaborator_checklist, project_checklist: chklst_1)
      collaborator_chklst_2 = create(:collaborator_checklist, project_checklist: chklst_2)

      collaborator_chklst_item_1 = create(:collaborator_checklist_item, collaborator_checklist: collaborator_chklst_1, project_checklist_item: chklst_item_1, checked: true)
      collaborator_chklst_item_1 = create(:collaborator_checklist_item, collaborator_checklist: collaborator_chklst_1, project_checklist_item: chklst_item_2, checked: false)
      collaborator_chklst_item_1 = create(:collaborator_checklist_item, collaborator_checklist: collaborator_chklst_2, project_checklist_item: chklst_item_3, checked: false)


      project.reload

      expect(project.progress.round(2)).to eq 33.33
    end
  end
end
