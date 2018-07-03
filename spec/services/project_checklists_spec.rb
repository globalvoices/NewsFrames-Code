require 'rails_helper'

describe ProjectChecklists do

  describe described_class::Associate do

    it 'raises error if required parameters are not provided' do
      expect { described_class.(project: nil, checklist: create_checklist_english) }.to raise_error ArgumentError
      expect { described_class.(project: create(:project), checklists: nil) }.not_to raise_error
      expect { described_class.(project: create(:project), checklists: []) }.not_to raise_error
      expect { described_class.(project: create(:project)) }.not_to raise_error
    end

    it 'associates new checklists with project' do
      checklist_1 = create_checklist_english
      checklist_2 = create_checklist_english
      checklist_3 = create_checklist_english

      project = create(:project)

      expect(project.checklists.length).to eq 0

      described_class.(project: project, checklists: [checklist_1, checklist_2])
      project.reload

      expect(project.checklists.length).to eq 2
      expect(project.has_checklist?(checklist_1)).to eq true
      expect(project.has_checklist?(checklist_2)).to eq true
      expect(project.has_checklist?(checklist_3)).to eq false
    end

    it 'removes existing checklists from project' do
      project = create(:project)

      checklist_1 = create_checklist_english
      checklist_2 = create_checklist_english
      checklist_3 = create_checklist_english

      project_checklist_1 = create_project_checklist_english(project, checklist_1)
      project_checklist_2 = create_project_checklist_english(project, checklist_2)

      expect(project.checklists.length).to eq 2
      expect(project.has_checklist?(checklist_1)).to eq true
      expect(project.has_checklist?(checklist_2)).to eq true
      expect(project.has_checklist?(checklist_3)).to eq false

      described_class.(project: project, checklists: [checklist_1])
      project.reload

      expect(project.checklists.length).to eq 1
      expect(project.has_checklist?(checklist_1)).to eq true
      expect(project.has_checklist?(checklist_2)).to eq false
      expect(project.has_checklist?(checklist_3)).to eq false
    end

    it 'removes all checklists from project' do
      project = create(:project)

      checklist_1 = create_checklist_english
      checklist_2 = create_checklist_english
      checklist_3 = create_checklist_english

      project_checklist_1 = create_project_checklist_english(project, checklist_1)
      project_checklist_2 = create_project_checklist_english(project, checklist_2)

      expect(project.checklists.length).to eq 2
      expect(project.has_checklist?(checklist_1)).to eq true
      expect(project.has_checklist?(checklist_2)).to eq true
      expect(project.has_checklist?(checklist_3)).to eq false

      described_class.(project: project)
      project.reload

      expect(project.checklists.length).to eq 0
      expect(project.has_checklist?(checklist_1)).to eq false
      expect(project.has_checklist?(checklist_2)).to eq false
      expect(project.has_checklist?(checklist_3)).to eq false
    end

    it 'adds new checklists and removes existing checklists from project' do
      project = create(:project)

      checklist_1 = create_checklist_english
      checklist_2 = create_checklist_english
      checklist_3 = create_checklist_english

      project_checklist_1 = create_project_checklist_english(project, checklist_1)
      project_checklist_2 = create_project_checklist_english(project, checklist_2)

      expect(project.checklists.length).to eq 2
      expect(project.has_checklist?(checklist_1)).to eq true
      expect(project.has_checklist?(checklist_2)).to eq true
      expect(project.has_checklist?(checklist_3)).to eq false

      described_class.(project: project, checklists: [checklist_3])
      project.reload

      expect(project.checklists.length).to eq 1
      expect(project.has_checklist?(checklist_1)).to eq false
      expect(project.has_checklist?(checklist_2)).to eq false
      expect(project.has_checklist?(checklist_3)).to eq true
    end

    it 'keeps zombie checklists associated with the project' do
      project = create(:project)
      checklist_1 = create_checklist_english
      checklist_2 = create_checklist_english

      project_checklist_1 = create_project_checklist_english(project, checklist_1)
      expect(project.checklists.length).to eq 1
      checklist_1.destroy!
      expect(project.checklists.length).to eq 1

      described_class.(project: project, checklists: [checklist_2], zombie_checklists: [project_checklist_1])
      project.reload
      expect(project.checklists.length).to eq 2
    end

    it 'removes zombie checklists associated with the project' do
      project = create(:project)
      checklist_1 = create_checklist_english
      checklist_2 = create_checklist_english

      project_checklist_1 = create_project_checklist_english(project, checklist_1)
      expect(project.checklists.length).to eq 1
      checklist_1.destroy!
      expect(project.checklists.length).to eq 1

      described_class.(project: project, checklists: [checklist_2])
      project.reload
      expect(project.checklists.length).to eq 1
    end
  end

  describe described_class::Create do
    it 'raises error if required parameters are not provided' do
      expect { described_class.(project: create(:project), checklist: nil) }.to raise_error ArgumentError
      expect { described_class.(project: nil, checklist: create_checklist_english) }.to raise_error ArgumentError
    end

    it 'does nothing if checklist is already associated with the project' do
      project = create(:project)
      chklst = create_checklist_english
      proj_chklst = create_project_checklist_english(project, chklst)

      expect(project.checklists.length).to eq 1
      expect(project.checklists[0].id).to eq proj_chklst.id

      described_class.(checklist: proj_chklst.checklist, project: proj_chklst.project)
      project.reload

      expect(project.checklists.length).to eq 1
      expect(project.checklists[0].id).to eq proj_chklst.id
    end

    it 'associates the specified checklist with the project' do
      chklst = create_checklist_english

      project = create(:project)

      expect(project.checklists.length).to eq 0

      proj_chklst = described_class.(project: project, checklist: chklst)
      project.reload

      expect(project.checklists.length).to eq 1
      expect(project.checklists.first).to eq proj_chklst
      expect(project.checklists.first.global_checklist).to eq chklst
      expect(project.checklists.first.name_en_us).to eq chklst.name_en_us
      expect(project.checklists.first.items.length).to eq chklst.items.length
      expect(project.checklists.first.items.first.item_en_us).to eq chklst.items[0].item_en_us
      expect(project.checklists.first.items.first.help_en_us).to eq chklst.items[0].help_en_us
      expect(project.checklists.first.items.last.item_en_us).to eq chklst.items[1].item_en_us
      expect(project.checklists.first.items.last.help_en_us).to eq chklst.items[1].help_en_us
    end
  end

  describe described_class::Destroy do
    it 'raises error if required parameters are not provided' do
      expect { described_class.(project: create(:project), checklist: nil) }.to raise_error ArgumentError
      expect { described_class.(project: nil, checklist: create_project_checklist_english) }.to raise_error ArgumentError
    end

    it 'does nothing if checklist is not associated with the project' do
      proj_chklst_1 = create_project_checklist_english
      proj_chklst_2 = create_project_checklist_english
      project = proj_chklst_1.project

      expect(project.checklists.length).to eq 1
      expect(project.checklists[0].id).to eq proj_chklst_1.id

      described_class.(checklist: proj_chklst_2, project: project)
      project.reload

      expect(project.checklists.length).to eq 1
      expect(project.checklists[0].id).to eq proj_chklst_1.id
    end

    it 'associates the specified checklist from the project' do
      project = create(:project)
      proj_chklst_1 = create_project_checklist_english project
      proj_chklst_2 = create_project_checklist_english project

      expect(project.checklists.length).to eq 2

      described_class.(project: project, checklist: proj_chklst_1)
      project.reload

      expect(project.checklists.length).to eq 1
      expect(project.checklists.first).to eq proj_chklst_2
      expect { proj_chklst_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
