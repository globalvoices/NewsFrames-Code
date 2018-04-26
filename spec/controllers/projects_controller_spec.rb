require 'rails_helper'

describe ProjectsController do
  before { bypass_rescue }

  describe '#index' do
    let!(:user) { create(:user) }
    let!(:project1) { create(:project) }
    let!(:project2) { create(:project) }
    let!(:project3) { create(:project) }

    before do
      create(:collaborator, project: project1, user: user, lead: true)
      create(:collaborator, project: project2, user: user)
      sign_in(user)
    end

    it 'assigns lead projects' do
      get :index
      expect(assigns(:lead_projects)).to include project1
      expect(assigns(:lead_projects)).to_not include project2
      expect(assigns(:lead_projects)).to_not include project3
    end

    it 'assigns shared projects' do
      get :index
      expect(assigns(:shared_projects)).to_not include project1
      expect(assigns(:shared_projects)).to include project2
      expect(assigns(:shared_projects)).to_not include project3
    end
  end

  describe '#new' do
    before { allow_any_instance_of(ProjectPolicy).to receive(:new?) { true } }

    it 'assigns project form' do
      expect_any_instance_of(ProjectPolicy).to receive(:new?)

      get :new
      expect(assigns(:form)).to be_a ProjectForm
    end

    it 'renders new template' do
      expect_any_instance_of(ProjectPolicy).to receive(:new?)

      get :new
      expect(controller).to render_template :new
    end
  end

  describe '#create' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:params) { { project: attributes_for(:project) } }

    before do
      sign_in(user)
      allow_any_instance_of(ProjectPolicy).to receive(:create?) { true }
      allow_any_instance_of(ProjectForm).to receive(:valid?) { true }
      allow_any_instance_of(ProjectForm).to receive(:project) { project }
    end

    it 'calls project form save'   do
      expect_any_instance_of(ProjectPolicy).to receive(:create?)
      expect_any_instance_of(ProjectForm).to receive(:valid?)
      expect_any_instance_of(ProjectForm).to receive(:save!)

      post :create, params: params
      expect(assigns(:form)).to be_a ProjectForm
    end

    it 'redirects to project path' do
      post :create, params: params
      expect(controller).to redirect_to project_path(project)
    end

    context 'form invalid' do
      before { allow_any_instance_of(ProjectForm).to receive(:valid?) { false } }
      it 'assigns form' do
        post :create, params: params
        expect(assigns(:form)).to be_a ProjectForm
      end

      it 'renders new template' do
        post :create, params: params
        expect(controller).to render_template :new
      end
    end

    context 'form throws error' do
      before { allow_any_instance_of(ProjectForm).to receive(:save!).and_raise(ActiveRecord::RecordInvalid) }
      it 'assigns form' do
        post :create, params: params
        expect(assigns(:form)).to be_a ProjectForm
      end

      it 'renders new template' do
        post :create, params: params
        expect(controller).to render_template :new
      end
    end
  end

  describe '#show' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:params) { { id: project.id } }

    before do
      sign_in(user)
      allow_any_instance_of(ProjectPolicy).to receive(:show?) { true }
      allow(Etherpad::GetPad).to receive(:call).with(pad_id: project.primary_pad.pad_id) { double(:pad, group: double(id: 'group-id')) }
    end

    it 'assigns project' do
      get :show, params: params
      expect(assigns(:project)).to eq project
    end

    it 'renders show template' do
      get :show, params: params
      expect(controller).to render_template :show
    end
  end

  describe "#pads" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:params) { { project_id: project.id } }

    before do
      sign_in(user)
      allow_any_instance_of(ProjectPolicy).to receive(:pads?) { true }
      allow_any_instance_of(ProjectPolicy).to receive(:show?) { true }
      allow(Etherpad::GetPad).to receive(:call).with(pad_id: project.primary_pad.pad_id) { double(:pad, group: double(id: 'group-id')) }
      allow(Etherpad::CreateSession).to receive(:call).with(author_id: user.author_id, group_id: 'group-id') { double(:session, id: 'session-id') }
    end

    it 'assigns project' do
      get :pads, params: params, xhr: true
      expect(assigns(:project)).to eq project
    end

    it 'renders show template' do
      get :pads, params: params, xhr: true
      expect(controller).to render_template :pads
    end

    context 'collaboration permission' do
      before { allow_any_instance_of(ProjectPolicy).to receive(:collaborate?) { true } }

      it 'sets Etherpad cookie' do
        get :pads, params: params, xhr: true
        expect(cookies[:sessionID]).to eq 'session-id'
      end
    end
  end

  describe '#edit' do
    let(:project) { create(:project) }
    let(:params) { { id: project.id } }

    before { allow_any_instance_of(ProjectPolicy).to receive(:edit?) { true } }

    it 'assigns project' do
      expect_any_instance_of(ProjectPolicy).to receive(:edit?)
      get :edit, params: params
      expect(assigns(:form)).to be_a ProjectForm
    end

    it 'renders edit template' do
      get :edit, params: params
      expect(controller).to render_template :edit
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:params) { { id: project.id, project: attributes_for(:project) } }

    before do
      sign_in(user)

      allow_any_instance_of(ProjectForm).to receive(:valid?) { true }
      allow_any_instance_of(ProjectForm).to receive(:project) { project }
      allow_any_instance_of(ProjectPolicy).to receive(:update?) { true }
    end

    it 'calls project form save' do
      expect_any_instance_of(ProjectPolicy).to receive(:update?)
      expect_any_instance_of(ProjectForm).to receive(:valid?)
      expect_any_instance_of(ProjectForm).to receive(:save!)

      patch :update, params: params
      expect(assigns(:form)).to be_a ProjectForm
    end

    it 'redirects to project path' do
      patch :update, params: params
      expect(controller).to redirect_to project_path(project)
    end

    context 'form invalid' do
      before { allow_any_instance_of(ProjectForm).to receive(:valid?) { false } }
      it 'assigns form' do
        patch :update, params: params
        expect(assigns(:form)).to be_a ProjectForm
      end

      it 'renders new template' do
        patch :update, params: params
        expect(controller).to render_template :edit
      end
    end

    context 'form throws error' do
      before { allow_any_instance_of(ProjectForm).to receive(:save!).and_raise(ActiveRecord::RecordInvalid) }
      it 'assigns form' do
        patch :update, params: params
        expect(assigns(:form)).to be_a ProjectForm
      end

      it 'renders new template' do
        patch :update, params: params
        expect(controller).to render_template :edit
      end
    end
  end

  describe '#destroy' do
    let(:project) { create(:project) }
    let(:params) { { id: project.id } }

    before do
      allow_any_instance_of(ProjectPolicy).to receive(:destroy?) { true }
      allow(Projects::Delete).to receive(:call)
    end

    it 'calls project delete service' do
      expect(Projects::Delete).to receive(:call).with(project: project)
      delete :destroy, params: params
    end

    it 'redirects to projects path' do
      delete :destroy, params: params
      expect(controller).to redirect_to projects_path
    end
  end
end
