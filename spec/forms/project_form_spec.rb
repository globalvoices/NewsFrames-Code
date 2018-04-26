require 'rails_helper'

describe ProjectForm do

  it 'has valid factory' do
    expect(create(:project_form)).to be_valid
  end  

  it 'validates the presence of mandatory items' do
    expect(build(:project_form, user: nil)).to_not be_valid
    expect(build(:project_form, name: nil)).to_not be_valid
    expect(build(:project_form, project: nil)).to_not be_valid
  end

  describe '#initialize' do
    let(:name) { Faker::Lorem.word }
    let(:project) { create(:project) }
    let!(:checklist_1) { create_checklist_english }
    let!(:checklist_2) { create_checklist_english }

    it 'uses the name provided during initialization or from project' do
      form = ProjectForm.new(name: name, project: project)
      expect(form.name).to eq name
      expect(form.name).to_not eq project.name

      form = ProjectForm.new(project: project)
      expect(form.name).to eq project.name
      expect(form.name).to_not eq name
    end

    it 'initializes internal checklist variable' do
      form = ProjectForm.new(name: name, project: project)
      expect(form.send(:global_checklists).length).to eq 2
      expect(form.send(:selected_checklists).length).to eq 0
      expect(form.send(:global_checklists)[0].id).to eq checklist_1.id
      expect(form.send(:global_checklists)[1].id).to eq checklist_2.id

      form = ProjectForm.new(name: name, project: project, selected_checklists: ['', checklist_2.id.to_s])
      expect(form.send(:global_checklists).length).to eq 0
      expect(form.send(:selected_checklists).length).to eq 1
      expect(form.send(:selected_checklists)[0]).to eq checklist_2.id.to_s

      project_checklist = create_project_checklist_english project, checklist_1
      project.reload
      form = ProjectForm.new(name: name, project: project)
      expect(form.send(:global_checklists).length).to eq 2
      expect(form.send(:selected_checklists).length).to eq 1
      expect(form.send(:selected_checklists)[0]).to eq checklist_1.id
    end

    it 'initializes internal checklist variables for zombie checklists' do
      project_checklist = create_project_checklist_english project, checklist_1
      checklist_1.destroy!

      form = ProjectForm.new(name: name, project: project)
      expect(form.send(:global_checklists).length).to eq 1
      expect(form.send(:global_checklists)[0].id).to eq checklist_2.id
      expect(form.send(:deleted_global_checklists).length).to eq 1
      expect(form.send(:deleted_global_checklists)[0].id).to eq project_checklist.id
      expect(form.send(:selected_checklists).length).to eq 0
      expect(form.send(:zombie_checklists).length).to eq 1
      expect(form.send(:zombie_checklists)[0]).to eq project_checklist.id
    end
  end

  describe '#save!' do
    it 'calls project save service' do
      form = build(:project_form)
      expect(Projects::Save).to receive(:call) do |params|
        expect(params[:project]).to eq form.project
        expect(params[:lead]).to eq form.user
      end
      form.save!
    end

    it 'calls project_checklists associate service with empty checklists' do
      form = build(:project_form)
      expect(ProjectChecklists::Associate).to receive(:call) do |params|
        expect(params[:project]).to eq form.project
        expect(params[:checklists]).to eq []
      end
      form.save!
    end

    it 'calls project_checklists associate service with non-empty checklists' do
      checklist = create_checklist_english
      form = build(:project_form, selected_checklists: [checklist.id])
      expect(ProjectChecklists::Associate).to receive(:call) do |params|
        expect(params[:project]).to eq form.project
        expect(params[:checklists]).to eq [checklist]
      end
      form.save!
    end
  end
  
end