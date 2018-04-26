require 'rails_helper'

describe Queries do
  describe described_class::FetchData do
    let(:query) { create(:query) }
    let(:mc_query) { double(:mc_query) }

    before do
      allow_any_instance_of(MediaCloudQuery).to receive(:build) { mc_query }
      allow(mc_query).to receive(:perform) { 'test' }
    end

    it 'performs MC query' do
      expect(mc_query).to receive(:perform)
      described_class.(query: query, query_type: :wordcount)
    end

    it 'returns data returned from MC query' do
      data = described_class.(query: query, query_type: :wordcount)
      expect(data[:wordcount]).to eq ['test', 'test']
    end
  end

  describe described_class::DownloadFullData do
    let(:query) { create(:query) }

    before { allow(Queries::FetchData).to receive(:call) }

    it 'calls fetch data for each partial query' do
      expect(Queries::FetchData).to receive(:call).once.with(query: query, options: { full: true })
      described_class.(query: query)
    end

    it 'marks query data as full' do
      described_class.(query: query)
      expect(query.reload.full_data).to eq true
    end
  end

  describe described_class::Save do
    let(:query) { build(:query) }

    it 'saves query record' do
      expect { described_class.(query: query) }.to change { Query.count }.by 1
    end

    context 'with fetch data param' do
      it 'calls fetch data service' do
        expect(Queries::FetchData).to receive(:call)
        described_class.(query: query, fetch_data: true)
      end
    end
  end
end
