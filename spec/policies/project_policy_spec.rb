require 'rails_helper'

describe ProjectPolicy do
  let(:user) { create(:user) }
  let(:unapproved) { create(:user, approved: false) }
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }
  let(:collaborator) { create(:collaborator, project: project) }
  let(:lead_collaborator) { create(:collaborator, project: project, lead: true) }

  subject { described_class }

  permissions :index? do
    it { expect(subject).to permit(nil, project) }
    it { expect(subject).to permit(user, project) }
    it { expect(subject).to permit(unapproved, project) }
    it { expect(subject).to permit(lead_collaborator.user, project) }
    it { expect(subject).to permit(collaborator.user, project) }
    it { expect(subject).to permit(admin, project) }
  end

  permissions :create? do
    it { expect(subject).to_not permit(nil, project) }
    it { expect(subject).to permit(user, project) }
    it { expect(subject).to_not permit(unapproved, project) }
    it { expect(subject).to permit(lead_collaborator.user, project) }
    it { expect(subject).to permit(collaborator.user, project) }
    it { expect(subject).to permit(admin, project) }
  end

  permissions :show? do
    it { expect(subject).to_not permit(nil, project) }
    it { expect(subject).to_not permit(user, project) }
    it { expect(subject).to_not permit(unapproved, project) }
    it { expect(subject).to permit(lead_collaborator.user, project) }
    it { expect(subject).to permit(collaborator.user, project) }
    it { expect(subject).to permit(admin, project) }

    context 'public' do
      before { project.public = true }

      it { expect(subject).to permit(nil, project) }
      it { expect(subject).to permit(user, project) }
      it { expect(subject).to permit(unapproved, project) }
      it { expect(subject).to permit(lead_collaborator.user, project) }
      it { expect(subject).to permit(collaborator.user, project) }
      it { expect(subject).to permit(admin, project) }
    end
  end

  permissions :collaborate?, :pads? do
    it { expect(subject).to_not permit(nil, project) }
    it { expect(subject).to_not permit(user, project) }
    it { expect(subject).to_not permit(unapproved, project) }
    it { expect(subject).to permit(lead_collaborator.user, project) }
    it { expect(subject).to permit(collaborator.user, project) }
    it { expect(subject).to permit(admin, project) }
  end

  permissions :update?, :checklist_report? do
    it { expect(subject).to_not permit(nil, project) }
    it { expect(subject).to_not permit(user, project) }
    it { expect(subject).to_not permit(unapproved, project) }
    it { expect(subject).to permit(lead_collaborator.user, project) }
    it { expect(subject).to_not permit(collaborator.user, project) }
    it { expect(subject).to permit(admin, project) }
  end

  permissions :destroy? do
    it { expect(subject).to_not permit(nil, project) }
    it { expect(subject).to_not permit(user, project) }
    it { expect(subject).to_not permit(unapproved, project) }
    it { expect(subject).to_not permit(lead_collaborator.user, project) }
    it { expect(subject).to_not permit(collaborator.user, project) }
    it { expect(subject).to permit(admin, project) }
  end

  describe described_class::Scope do
    describe '#resolve' do
      let(:lead) { create(:user) }

      let!(:project1) { create(:project) }
      let!(:project2) { create(:project) }
      let!(:project3) { create(:project) }

      before do
        create(:collaborator, project: project1, user: lead, lead: true)
        create(:collaborator, project: project2, user: lead, lead: true)
      end

      context 'anonymous' do
        subject { described_class.new(nil, Project.all) }

        it { expect(subject.resolve).to be_empty }
      end

      context 'unapproved' do
        subject { described_class.new(unapproved, Project.all) }

        it { expect(subject.resolve).to be_empty }
      end

      context 'approved' do
        subject { described_class.new(user, Project.all) }

        it { expect(subject.resolve).to be_empty }
      end

      context 'project lead' do
        subject { described_class.new(lead, Project.all) }

        it 'returns projects led by given user' do
          projects = subject.resolve
          expect(projects).to include project1
          expect(projects).to include project2
          expect(projects).to_not include project3
        end
      end

      context 'admin' do
        subject { described_class.new(admin, Project.all) }

        it 'returns all projects' do
          projects = subject.resolve
          expect(projects).to include project1
          expect(projects).to include project2
          expect(projects).to include project3
        end
      end
    end
  end
end
