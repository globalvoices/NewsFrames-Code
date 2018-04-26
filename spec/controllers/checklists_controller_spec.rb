require 'rails_helper'

describe ChecklistsController do
  let(:project) { create(:project) }
  let!(:user) { create(:user) }
  let!(:collaborator) { create(:collaborator, user: user, project: project) }

  before { bypass_rescue }  
  before { allow_any_instance_of(ProjectPolicy).to receive(:show?) { true } }
  before { sign_in(user) }


  describe '#index' do
    before { allow_any_instance_of(CollaboratorChecklistPolicy).to receive(:index?) { true } }
    let(:params) { { project_id: project.id } }

    it 'assigns custom form' do
      expect_any_instance_of(CollaboratorChecklistPolicy).to receive(:index?)

      get :index, params: params, xhr: true
      expect(assigns(:checklists_form)).to be_a ProjectChecklistsForm
    end

    it 'renders index template' do
      get :index, params: params, xhr: true
      expect(controller).to render_template :index
    end
  end

  describe '#check' do
    let(:params) { { project_id: project.id, collaborator_checklist: { selected_checklist_items: [ '', '1' ] } } }

    before do
      allow_any_instance_of(CollaboratorChecklistPolicy).to receive(:check_item?) { true }
      allow_any_instance_of(ProjectChecklistsForm).to receive(:valid?) { true }
      allow_any_instance_of(ProjectChecklistsForm).to receive(:save!) { true }
    end

    it 'calls form save' do
      expect_any_instance_of(CollaboratorChecklistPolicy).to receive(:check_item?)
      expect_any_instance_of(ProjectChecklistsForm).to receive(:valid?)
      expect_any_instance_of(ProjectChecklistsForm).to receive(:save!)

      put :check, params: params, xhr: true
      expect(assigns(:checklists_form)).to be_a ProjectChecklistsForm
    end

    it 'renders check template' do
      put :check, params: params, xhr: true
      expect(controller).to render_template :check
    end

    context 'form invalid' do
      before { allow_any_instance_of(ProjectChecklistsForm).to receive(:valid?) { false } }
      
      it 'renders check template' do
        put :check, params: params, xhr: true
        expect(assigns(:checklists_form)).to be_a ProjectChecklistsForm
        expect(controller).to render_template :check
      end
    end

    context 'form throws error' do
      before { allow_any_instance_of(ProjectChecklistsForm).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(project)) }
      it 'renders check template' do
        put :check, params: params, xhr: true
        expect(assigns(:checklists_form)).to be_a ProjectChecklistsForm
        expect(controller).to render_template :check
      end
    end
  end
end