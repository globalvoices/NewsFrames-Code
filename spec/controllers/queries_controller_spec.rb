require 'rails_helper'

describe QueriesController do
  let(:project) { create(:project) }
  let(:params) { { project_id: project.id } }

  before { allow_any_instance_of(ProjectPolicy).to receive(:collaborate?) { true } }

  describe '#index' do
    let!(:query1) { create(:query, project: project) }
    let!(:query2) { create(:query) }

    it 'assigns queries' do
      get :index, params: params, xhr: true
      expect(assigns(:queries)).to include query1
      expect(assigns(:queries)).to_not include query2
    end
  end

  describe '#new' do
    it 'assigns query' do
      get :new, params: params, xhr: true
      expect(assigns(:query).project).to eq project
    end
  end

  describe '#create' do
    let!(:query) { create(:query) }
    let(:params) { { project_id: project.id, query: { media_cloud_url: query.media_cloud_url } } }

    before do
      allow(Query).to receive(:new) { query }
      allow(Queries::Save).to receive(:call)
    end

    it 'calls query save service' do
      expect(Queries::Save).to receive(:call).with(query: query, fetch_data: true)
      post :create, params: params, xhr: true
    end

    it 'redirects to query path' do
      post :create, params: params, xhr: true
      expect(controller).to redirect_to project_query_path(project, query)
    end

    context 'record invalid' do
      before do
        allow(Queries::Save).to receive(:call).and_raise ActiveRecord::RecordInvalid
      end

      it 'renders new template' do
        post :create, params: params, xhr: true
        expect(controller).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let!(:query) { create(:query) }
    let(:params) { { project_id: project.id, id: query.id, query: { name: 'Testing' } } }

    it 'updates query attrs' do
      patch :update, params: params, xhr: true
      expect(query.reload.name).to eq 'Testing'
    end

    it 'calls query save service' do
      expect(Queries::Save).to receive(:call).with(query: query, fetch_data: false)
      patch :update, params: params, xhr: true
    end

    it 'redirects to query path' do
      patch :update, params: params, xhr: true
      expect(controller).to redirect_to project_query_path(project, query)
    end

    context 'record invalid' do
      before do
        allow(Queries::Save).to receive(:call).and_raise ActiveRecord::RecordInvalid
      end

      it 'renders edit template' do
        patch :update, params: params, xhr: true
        expect(controller).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    let!(:query) { create(:query) }
    let(:params) { { project_id: project.id, id: query.id } }

    it 'deletes query' do
      delete :destroy, params: params, xhr: true
      expect(Query.where(id: query.id)).to be_empty
    end
  end
end
