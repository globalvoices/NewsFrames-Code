require 'rails_helper'

describe Projects do
  describe described_class::Save do
    let(:lead) { create(:user) }
    let(:params) { { project: build(:project), lead: lead } }

    before { allow(Etherpad::CreatePad).to receive(:call) { double(id: 'pad-123') } }

    it 'saves project' do
      expect { described_class.(params) }.to change { Project.count }.by(1)
    end

    it 'creates lead collaborator' do
      expect { described_class.(params) }.to change { Collaborator.count }.by(1)
    end

    it 'creates primary project pad' do
      expect { described_class.(params) }.to change { ProjectPad.count }.by(1)
    end

    it 'calls etherpad create pad service' do
      expect(Etherpad::CreatePad).to receive(:call)
      described_class.(params)
    end

    it 'saves primary pad Etherpad ID' do
      project = described_class.(params)
      expect(project.reload.primary_pad.pad_id).to eq 'pad-123'
    end

    context 'existing project' do
      let!(:project) { create(:project) }
      let(:params) { { project: project } }

      it 'does not create new project pad' do
        expect { described_class.(params) }.to change { ProjectPad.count }.by(0)
      end
    end
  end

  describe described_class::SavePad do
    let!(:project) { create(:project) }
    let(:project_pad) { build(:project_pad, project: project, pad_id: nil) }

    before { allow(Etherpad::CreatePad).to receive(:call) { double(id: 'pad-123') } }

    it 'creates project pad' do
      expect { described_class.(project_pad: project_pad) }.to change { ProjectPad.count }.by 1
    end

    it 'assigns end index' do
      described_class.(project_pad: project_pad)
      expect(project_pad.index).to eq (project.project_pads.count - 1)
    end

    it 'calls etherpad create pad service and saves ID' do
      expect(Etherpad::CreatePad).to receive(:call)
      described_class.(project_pad: project_pad)
      expect(project_pad.pad_id).to eq 'pad-123'
    end
  end

  describe described_class::DeletePad do
    let!(:project) { create(:project) }
    let!(:project_pad) { create(:project_pad, project: project, index: 1) }

    before { allow(Etherpad::DeletePad).to receive(:call) }

    it 'deletes project pad' do
      expect { described_class.(project_pad: project_pad) }.to change { ProjectPad.count }.by(-1)
    end

    it 'calls etherpad delete pad service' do
      expect(Etherpad::DeletePad).to receive(:call).with(pad_id: project_pad.pad_id)
      described_class.(project_pad: project_pad)
    end
  end

  describe described_class::Delete do
    let!(:project) { create(:project) }
    let(:params) { { project: project } }

    before { allow(Etherpad::DeletePad).to receive(:call) }

    it 'deletes project' do
      expect { described_class.(params) }.to change { Project.count }.by(-1)
    end

    it 'deletes project pads' do
      expect { described_class.(params) }.to change { ProjectPad.count }.by(-1)
    end

    it 'calls etherpad delete pad service' do
      expect(Etherpad::DeletePad).to receive(:call).with(pad_id: project.primary_pad.pad_id)
      described_class.(params)
    end
  end
end
