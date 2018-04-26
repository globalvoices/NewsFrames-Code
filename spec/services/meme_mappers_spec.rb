require 'rails_helper'

describe MemeMappers do
  describe described_class::FetchData, vcr: true do
    let(:meme_mapper) { create(:meme_mapper) }

    it 'fetches and returns TinEye results' do
      results = described_class.(meme_mapper: meme_mapper)
      expect(results).to be_a Tinplate::SearchResults
    end
  end

  describe described_class::Save do
    let(:meme_mapper) { build(:meme_mapper) }

    it 'creates new meme mapper' do
      expect { described_class.(meme_mapper: meme_mapper) }.to change { MemeMapper.count }.by 1
    end

    context 'fetch data' do
      before do
        allow(MemeMappers::FetchData).to receive(:call).with(meme_mapper: meme_mapper) { { fake: 'results' } }
      end

      it 'saves result data' do
        described_class.(meme_mapper: meme_mapper, fetch_data: true)
        expect(meme_mapper.data).to eq({ 'fake' => 'results' })
      end
    end
  end
end
