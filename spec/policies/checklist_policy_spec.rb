require 'rails_helper'

describe ChecklistPolicy do
  let(:chklst) { create(:checklist) }
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }
  let(:collaborator) { create(:collaborator) }
  let(:lead_collaborator) { create(:lead_collaborator) }

  subject { described_class }

  permissions :index? do
    it { expect(subject).to_not permit(nil, chklst) }
    it { expect(subject).to_not permit(user, chklst) }
    it { expect(subject).to_not permit(collaborator.user, chklst) }
    it { expect(subject).to permit(admin, chklst) }
    it { expect(subject).to permit(lead_collaborator.user, chklst) }
  end

  permissions :create?, :destroy?, :edit_checklist?, :overwrite?,
              :add_translation?, :show_translation?, :edit_translation?,
              :upload_translation?, :overwrite_translation?, :remove_translation?,
              :enable?, :disable?, :import?, :upload_checklist? do
    it { expect(subject).to_not permit(nil, chklst) }
    it { expect(subject).to_not permit(user, chklst) }
    it { expect(subject).to_not permit(collaborator.user, chklst) }
    it { expect(subject).to_not permit(lead_collaborator.user, chklst) }
    it { expect(subject).to permit(admin, chklst) }
  end

  permissions :show? do
    it { expect(subject).to_not permit(nil, chklst) }
    it { expect(subject).to permit(user, chklst) }
    it { expect(subject).to permit(collaborator.user, chklst) }
    it { expect(subject).to permit(lead_collaborator.user, chklst) }
    it { expect(subject).to permit(admin, chklst) }
  end
end