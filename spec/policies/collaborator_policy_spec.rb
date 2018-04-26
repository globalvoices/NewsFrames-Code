require 'rails_helper'

describe CollaboratorPolicy do
  let!(:user) { create(:user) }
  let!(:admin) { create(:admin) }
  let!(:steward) { create(:steward) }
  let!(:project) { create(:project) }
  let!(:collaborator) { create(:collaborator, project: project) }
  let!(:lead_collaborator) { create(:lead_collaborator, project: project) }

  subject { described_class }

  permissions :index? do
    it { expect(subject).to_not permit(nil, collaborator) }
    it { expect(subject).to permit(user, collaborator) }
    it { expect(subject).to permit(collaborator.user, collaborator) }
    it { expect(subject).to permit(lead_collaborator.user, collaborator) }
    it { expect(subject).to permit(admin, collaborator) }
  end

  permissions :create? do
    it { expect(subject).to_not permit(nil, collaborator) }
    it { expect(subject).to_not permit(user, collaborator) }
    it { expect(subject).to_not permit(collaborator.user, collaborator) }
    it { expect(subject).to permit(lead_collaborator.user, collaborator) }
    it { expect(subject).to permit(steward, collaborator) }
    it { expect(subject).to permit(admin, collaborator) }
  end

  permissions :create_external? do
    it { expect(subject).to_not permit(nil, collaborator) }
    it { expect(subject).to_not permit(user, collaborator) }
    it { expect(subject).to_not permit(collaborator.user, collaborator) }
    it { expect(subject).to_not permit(lead_collaborator.user, collaborator) }
    it { expect(subject).to permit(steward, collaborator) }
    it { expect(subject).to permit(admin, collaborator) }
  end

  permissions :destroy? do
    it { expect(subject).to_not permit(nil, collaborator) }
    it { expect(subject).to_not permit(user, collaborator) }
    it { expect(subject).to permit(collaborator.user, collaborator) }
    it { expect(subject).to permit(lead_collaborator.user, collaborator) }
    it { expect(subject).to permit(admin, collaborator) }

    context 'sole lead' do
      before { collaborator.destroy }

      it { expect(subject).to_not permit(lead_collaborator.user, lead_collaborator) }
      it { expect(subject).to permit(admin, lead_collaborator) }
    end
  end

  permissions :promote? do
    it { expect(subject).to_not permit(nil, collaborator) }
    it { expect(subject).to_not permit(user, collaborator) }
    it { expect(subject).to_not permit(collaborator.user, collaborator) }
    it { expect(subject).to permit(lead_collaborator.user, collaborator) }
    it { expect(subject).to permit(admin, collaborator) }
  end
end
