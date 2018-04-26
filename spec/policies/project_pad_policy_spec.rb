require 'rails_helper'

describe ProjectPadPolicy do
  subject { described_class }

  permissions :create?, :update? do
    let!(:project) { create(:project) }

    context 'project collaborate permission' do
      before { allow_any_instance_of(ProjectPolicy).to receive(:collaborate?) { true } }

      it { expect(subject).to permit(nil, project.primary_pad) }
    end

    context 'no project collaborate permission' do
      before { allow_any_instance_of(ProjectPolicy).to receive(:collaborate?) { false } }

      it { expect(subject).to_not permit(nil, project.primary_pad) }
    end
  end

  permissions :destroy? do
    let!(:project) { create(:project) }
    let!(:project_pad) { create(:project_pad, project: project, index: 1) }

    context 'project collaborate permission' do
      before { allow_any_instance_of(ProjectPolicy).to receive(:collaborate?) { true } }

      it { expect(subject).to_not permit(nil, project.primary_pad) }
      it { expect(subject).to permit(nil, project_pad) }
    end

    context 'no project collaborate permission' do
      before { allow_any_instance_of(ProjectPolicy).to receive(:collaborate?) { false } }

      it { expect(subject).to_not permit(nil, project.primary_pad) }
      it { expect(subject).to_not permit(nil, project_pad) }
    end
  end
end
