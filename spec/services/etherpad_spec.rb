require 'rails_helper'

describe Etherpad do
  describe described_class::CreatePad, vcr: true do
    it 'creates Etherpad pad' do
      result = described_class.(name: SecureRandom.uuid)
      expect(result).to be_a EtherpadLite::Pad
      pad = Etherpad.instance.pad(result.id)
      expect(pad).to be_a EtherpadLite::Pad
    end

    it 'creates Etherpad group' do
      result = described_class.(name: SecureRandom.uuid)
      expect(result.group).to be_a EtherpadLite::Group
      group = Etherpad.instance.get_group(result.group.id)
      expect(group).to be_a EtherpadLite::Group
    end
  end

  describe described_class::GetPad, vcr: true do
    let!(:pad) { Etherpad.instance.create_pad(SecureRandom.uuid) }

    it 'returns Etherpad pad' do
      result = described_class.(pad_id: pad.id)
      expect(result).to be_a EtherpadLite::Pad
      expect(result.id).to eq pad.id
    end
  end

  describe described_class::DeletePad, vcr: true do
    let!(:group) { Etherpad.instance.create_group }
    let!(:pad) { group.create_pad('test') }

    it 'deletes Etherpad pad' do
      described_class.(pad_id: pad.id)
      expect { pad.text }.to raise_error EtherpadLite::Error
    end

    it 'deletes Etherpad group' do
      described_class.(pad_id: pad.id)
      expect { group.pads }.to raise_error EtherpadLite::Error
    end
  end

  describe described_class::CreateAuthor, vcr: true do
    it 'creates Etherpad author' do
      result = described_class.()
      expect(result).to be_a EtherpadLite::Author
      author = Etherpad.instance.author(result.id)
      expect(author).to be_a EtherpadLite::Author
    end
  end

  describe described_class::CreateSession, vcr: true do
    let!(:author) { Etherpad.instance.create_author(name: SecureRandom.uuid) }
    let!(:group) { Etherpad.instance.create_group }

    it 'creates Etherpad session' do
      result = described_class.(author_id: author.id, group_id: group.id)
      expect(result).to be_a EtherpadLite::Session
      expect(result.author.id).to eq author.id
      expect(result.group.id).to eq group.id
    end
  end

  describe described_class::GetSession, vcr: true do
    # Note that if you re-record the VCR cassettes for these specs, the timestamp
    # here will need to be updated.
    # It should be within 1 hour of when the requests were recorded.
    let(:timestamp) { DateTime.new(2017, 4, 27, 13, 0, 0) }

    let!(:author) { Etherpad.instance.create_author(name: SecureRandom.uuid) }
    let!(:group) { Etherpad.instance.create_group }
    let!(:session) { group.create_session(author, 60) }

    it 'returns Etherpad session' do
      Timecop.freeze(timestamp) do
        result = described_class.(session_id: session.id)
        expect(result).to be_a EtherpadLite::Session
      end
    end

    context 'expired' do
      before { allow_any_instance_of(EtherpadLite::Session).to receive(:expired?) { true } }

      it 'returns nil' do
        result = described_class.(session_id: session.id)
        expect(result).to eq nil
      end

      it 'deletes expired Etherpad session' do
        session_id = session.id
        described_class.(session_id: session.id)
        session = Etherpad.instance.get_session(session_id)
        expect { session.valid? }.to raise_error EtherpadLite::Error
      end
    end
  end
end
