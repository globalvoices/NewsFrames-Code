require 'rails_helper'

describe UserPolicy do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:another_admin) { create(:admin) }

  subject { described_class }

  permissions :index?, :approve?, :enable?, :disable? do
    it { expect(subject).to_not permit(nil, user) }
    it { expect(subject).to_not permit(user, user) }
    it { expect(subject).to_not permit(another_user, user) }
    it { expect(subject).to permit(admin, user) }    
  end

  permissions :disable? do
    it { expect(subject).to_not permit(admin, another_admin) }
  end

  permissions :show?, :update? do
    it { expect(subject).to_not permit(nil, user) }
    it { expect(subject).to_not permit(another_user, user) }
    it { expect(subject).to permit(user, user) }
    it { expect(subject).to permit(admin, user) }
  end

  permissions :create? do
    it { expect(subject).to permit(nil) }
    it { expect(subject).to_not permit(another_user) }
    it { expect(subject).to permit(admin) }
  end
end