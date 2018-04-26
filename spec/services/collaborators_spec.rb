require 'rails_helper'

describe Collaborators do
  describe described_class::Invite do
    let!(:project) { create(:project) }
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let(:emails) { [user1.email, user2.email] }
    let(:users_hash) { [ {email: user1.email, user: user1}, {email: user2.email, user: user2}] }
    
    let!(:admin) { create(:admin) }

    it 'creates collaboration for each email' do
      expect { described_class.(users_hash: users_hash, project: project) }.to change { Collaborator.count }.by 2
      expect(project.collaborators.first.user).to eq user1
      expect(project.collaborators.last.user).to eq user2
    end

    context 'no existing account' do
      let(:external_email) { Faker::Internet.email }
      let(:emails) { [user1.email, user2.email, external_email] }
      let(:users_hash) { [ {email: user1.email, user: user1}, {email: user2.email, user: user2}, {email: external_email, user: nil} ] }
    

      before { allow(Users::Approve).to receive(:call) }

      it 'creates collaboration for each email' do
        expect { described_class.(users_hash: users_hash, project: project) }.to change { Collaborator.count }.by 3
        expect(project.collaborators.first.user).to eq user1
        expect(project.collaborators.second.user).to eq user2
      end

      it 'sends an email to each email' do
        expect { described_class.(users_hash: users_hash, project: project) }.to change { ActionMailer::Base.deliveries.count }.by 3
      end

      it 'creates user for nonexistent account' do
        expect { described_class.(users_hash: users_hash, project: project) }.to change { User.count }.by 1
        expect(User.last.email).to eq emails.last
      end

      it 'calls user approve service for nonexistent account' do
        user = create(:user)
        expect(Invites::Create).to receive(:call).with(email: emails.last, skip_email: true) { user }
        expect(Users::Approve).to receive(:call).with(user: user, skip_email: true)
        described_class.(users_hash: users_hash, project: project)
      end
      
    end

    context 'project checklists' do
      it 'creates collaborator checklist each project checklist' do
        checklist_1 = create_checklist_english
        checklist_2 = create_checklist_english
        checklist_3 = create_checklist_english

        project_checklist_1 = create_project_checklist_english(project, checklist_1)
        project_checklist_2 = create_project_checklist_english(project, checklist_2)

        expect { described_class.(users_hash: users_hash, project: project) }.to change { CollaboratorChecklist.count }.by 4
      end
    end
  end

  describe described_class::Promote do
    let!(:collaborator) { create(:collaborator, lead: false) }

    it 'makes collaborator the project lead' do
      described_class.(collaborator: collaborator)
      expect(collaborator.lead).to eq true
    end

    it 'makes all other collaborators non-leads' do
      lead = create(:collaborator, project: collaborator.project, lead: true)
      described_class.(collaborator: collaborator)
      expect(collaborator.lead).to eq true
      expect(lead.reload.lead).to eq false
    end
  end

  describe described_class::Delete do
    let!(:collaborator) { create(:collaborator) }

    it 'deletes collaborator' do
      expect { described_class.(collaborator: collaborator) }.to change { Collaborator.count }.by(-1)
      expect(Collaborator.where(id: collaborator.id)).to be_empty
    end
  end
end
