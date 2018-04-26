require 'rails_helper'

describe CollaboratorsController do
  before { bypass_rescue }

  let(:project) { create(:project) }

  before { allow_any_instance_of(ProjectPolicy).to receive(:show?) { true } }

  describe '#index' do
    let!(:collaborators) { create_list(:collaborator, 3, project: project) }
    let(:params) { { project_id: project.id } }

    before { allow_any_instance_of(CollaboratorPolicy).to receive(:index?) { true } }

    it 'assigns project collaborators' do
      get :index, params: params, xhr: true
      expect(assigns(:collaborators)).to eq collaborators
    end

    it 'renders index template' do
      get :index, params: params, xhr: true
      expect(controller).to render_template :index
    end
  end

  describe '#invite' do
    let(:emails) { [Faker::Internet.email, Faker::Internet.email] }
    let(:params) { { project_id: project.id, emails: emails.join(' ') } }

    before { allow_any_instance_of(CollaboratorPolicy).to receive(:create?) { true } }
    before { allow_any_instance_of(CollaboratorPolicy).to receive(:create_external?) { true } }
    before { allow(Collaborators::Invite).to receive(:call) }

    it 'calls collaborator invite service' do
      expect(Collaborators::Invite).to receive(:call)
      post :invite, params: params, xhr: true
    end
  end

  describe '#promote' do
    let(:collaborator) { create(:collaborator) }
    let(:params) { { project_id: project.id, id: collaborator.id } }

    before { allow_any_instance_of(CollaboratorPolicy).to receive(:promote?) { true } }
    before { allow(Collaborators::Promote).to receive(:call) }

    it 'calls collaborator promote service' do
      expect(Collaborators::Promote).to receive(:call).with(collaborator: collaborator)
      post :promote, params: params, xhr: true
    end
  end

  describe '#destroy' do
    let!(:collaborator) { create(:collaborator, project: project) }
    let(:params) { { project_id: project.id, id: collaborator.id } }

    before { allow_any_instance_of(CollaboratorPolicy).to receive(:destroy?) { true } }
    before { allow(Collaborators::Delete).to receive(:call) }

    it 'calls collaborator delete service' do
      expect(Collaborators::Delete).to receive(:call).with(collaborator: collaborator)
      delete :destroy, params: params, xhr: true
    end
  end

  describe '#suggest' do
    let!(:user) { create(:user) }
    let!(:collaborator) { create(:collaborator, project: project) }
    let(:params) { { project_id: project.id } }

    it 'returns user emails' do
      get :suggest, params: params, xhr: true
      expect(json_response[:emails]).to include user.email
    end

    it 'excludes collaborator emails' do
      get :suggest, params: params, xhr: true
      expect(json_response[:emails]).to_not include collaborator.user.email
    end

    context 'with matching query' do
      let(:params) { { project_id: project.id, q: user.email[0] + user.email[1] } }

      it 'returns matching user emails' do
        get :suggest, params: params, xhr: true
        expect(json_response[:emails]).to include user.email
      end
    end

    context 'with nonmatching query' do
      let(:params) { { project_id: project.id, q: 'foo' } }

      it 'returns nothing' do
        get :suggest, params: params, xhr: true
        expect(json_response[:emails]).to be_empty
      end
    end
  end
end
