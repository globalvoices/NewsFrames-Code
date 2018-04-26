require 'rails_helper'

describe Query do
  it 'has a valid factory' do
    expect(create(:query)).to be_valid
  end

  describe 'validations' do
    it 'validates presence of MC URL' do
      expect(build(:query, media_cloud_url: nil)).to_not be_valid
    end
  end

  describe '#query_params' do
    let(:query) { create(:query) }

    it 'returns parsed MediaCloud query params' do
      expect(query.query_params.length).to eq 2
      expect(query.query_params.first).to be_a MediaCloud::QueryParams
    end
  end

  describe '#term' do
    context 'url' do
      let(:term) { 'https://explorer.mediacloud.org/#/queries/search?q=[{"label":"health","q":"health","color":"%23e14c11","startDate":"2017-6-4","endDate":"2017-6-4","sources":[],"collections":[8875027]},{"label":"gender","q":"gender","color":"%2320b1b8","startDate":"2017-6-4","endDate":"2017-6-4","sources":[],"collections":[8875027]}]' }

      it 'creates query with given MC URL' do
        query = Query.new(term: term)
        expect(query.media_cloud_url).to eq term
      end
    end

    context 'term' do
      let('term') { '"search term"' }

      it 'creates query with constructed MC URL' do
        Timecop.freeze(2017, 11, 9, 12, 0, 0)
        query = Query.new(term: term)
        expect(query.media_cloud_url).to eq 'https://explorer.mediacloud.org/#/queries/search?q=[{"label":"\"search term\"","q":"\"search term\"","startDate":"2016-11-09","endDate":"2017-11-09","sources":[],"collections":[9139487],"color":"%23000000"}]'
        Timecop.return
      end
    end
  end
end
