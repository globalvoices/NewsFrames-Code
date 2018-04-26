require 'rails_helper'

describe CollaboratorChecklistPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }

  let(:collaborator) { create(:collaborator, project: project) }
  let(:lead_collaborator) { create(:lead_collaborator, project: project) }
  let(:project_checklist) { create(:project_checklist, project: project) }
  let(:chklst) { create(:collaborator_checklist, collaborator: collaborator, project_checklist: project_checklist) }

  subject { described_class }

  permissions :index? do
    it { expect(subject).to_not permit(nil, chklst) }
    it { expect(subject).to_not permit(user, chklst) }
    it { expect(subject).to permit(admin, chklst) }
    it { expect(subject).to permit(collaborator.user, chklst) }
    it { expect(subject).to permit(lead_collaborator.user, chklst) }
  end

  permissions :create? do
    it { expect(subject).to_not permit(nil, chklst) }
    it { expect(subject).to_not permit(user, chklst) }
    it { expect(subject).to_not permit(admin, chklst) }
    it { expect(subject).to permit(collaborator.user, chklst) }
    it { expect(subject).to permit(lead_collaborator.user, chklst) }
  end

  permissions :destroy?, :check_item? do
    it { expect(subject).to_not permit(nil, chklst) }
    it { expect(subject).to_not permit(user, chklst) }
    it { expect(subject).to_not permit(admin, chklst) }
    it { expect(subject).to_not permit(lead_collaborator.user, chklst) }
    it { expect(subject).to permit(collaborator.user, chklst) }
  end

  permissions :show? do
    it { expect(subject).to_not permit(nil, chklst) }
    it { expect(subject).to_not permit(user, chklst) }
    it { expect(subject).to_not permit(admin, chklst) }
    it { expect(subject).to permit(collaborator.user, chklst) }
    it { expect(subject).to_not permit(lead_collaborator.user, chklst) }
  end
end