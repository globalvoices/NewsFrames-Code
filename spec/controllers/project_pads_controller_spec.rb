require 'rails_helper'

describe ProjectPadsController do
  let!(:project) { create(:project) }
  let!(:user) { create(:user) }

  before do
    bypass_rescue
    allow_any_instance_of(ProjectPolicy).to receive(:show?) { true }
    sign_in(user)
    allow(Etherpad::GetPad).to receive(:call) { double(:pad, group: double(id: 'group-id')) }
    allow(Etherpad::CreateSession).to receive(:call).with(author_id: user.author_id, group_id: 'group-id') { double(:session, id: 'session-id') }
  end

  describe '#new' do
    let(:params) { { project_id: project.id } }

    before { allow_any_instance_of(ProjectPadPolicy).to receive(:new?) { true } }

    it 'assigns project pad' do
      get :new, params: params, xhr: true
      expect(assigns(:project_pad)).to be_a ProjectPad
      expect(assigns(:project_pad).project).to eq project
    end

    it 'renders new template' do
      get :new, params: params, xhr: true
      expect(controller).to render_template :new
    end
  end

  describe '#create' do
    let(:params) { { project_id: project.id, project_pad: { name: Faker::Lorem.word } } }

    before { allow_any_instance_of(ProjectPadPolicy).to receive(:create?) { true } }
    before { allow(Projects::SavePad).to receive(:call) }

    it 'assigns project pad' do
      post :create, params: params, xhr: true
      expect(assigns(:project_pad)).to be_a ProjectPad
      expect(assigns(:project_pad).project).to eq project
    end

    it 'calls project save pad service' do
      expect(Projects::SavePad).to receive(:call).with(project_pad: kind_of(ProjectPad))
      post :create, params: params, xhr: true
    end

    it 'renders create template' do
      post :create, params: params, xhr: true
      expect(controller).to render_template :create
    end
  end

  describe '#edit' do
    let!(:project_pad) { create(:project_pad, project: project, index: 1) }
    let(:params) { { project_id: project.id, id: project_pad.id } }

    before { allow_any_instance_of(ProjectPadPolicy).to receive(:edit?) { true } }

    it 'assigns project pad' do
      get :edit, params: params, xhr: true
      expect(assigns(:project_pad)).to eq project_pad
    end

    it 'renders edit template' do
      get :edit, params: params, xhr: true
      expect(controller).to render_template :edit
    end
  end

  describe '#update' do
    let!(:project_pad) { create(:project_pad, project: project, index: 1) }
    let(:params) { { project_id: project.id, id: project_pad.id, project_pad: { name: Faker::Lorem.word } } }

    before { allow_any_instance_of(ProjectPadPolicy).to receive(:update?) { true } }
    before { allow(Projects::SavePad).to receive(:call) }

    it 'assigns project pad' do
      patch :update, params: params, xhr: true
      expect(assigns(:project_pad)).to eq project_pad
    end

    it 'calls project save pad service' do
      expect(Projects::SavePad).to receive(:call).with(project_pad: project_pad)
      patch :update, params: params, xhr: true
    end

    it 'renders update template' do
      patch :update, params: params, xhr: true
      expect(controller).to render_template :update
    end
  end

  describe '#destroy' do
    let!(:project_pad) { create(:project_pad, project: project, index: 1) }
    let(:params) { { project_id: project.id, id: project_pad.id } }

    before { allow_any_instance_of(ProjectPadPolicy).to receive(:destroy?) { true } }
    before { allow(Projects::DeletePad).to receive(:call) }

    it 'calls project delete pad service' do
      expect(Projects::DeletePad).to receive(:call).with(project_pad: project_pad)
      delete :destroy, params: params, xhr: true
    end

    it 'renders destroy template' do
      delete :destroy, params: params, xhr: true
      expect(controller).to render_template :destroy
    end
  end
end
