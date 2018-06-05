# coding: utf-8
require 'spec_helper'

describe MediaCloud do
  describe '.parse_url' do
    let(:url) { 'https://explorer.mediacloud.org/#/queries/search?q=[{"label":"Foo","q":"foo","color":"%23e14c11","startDate":"2017-01-01","endDate":"2017-01-03","sources":[],"collections":[123]},{"label":"Bar","q":"bar í","color":"%2320b1b8","startDate":"2017-01-02","endDate":"2017-01-04","sources":[],"collections":[456]}]' }

    it 'parses JSON from URL query fragment' do
      result = described_class.parse_url(url)
      expect(result.length).to eq 2

      expect(result.first).to be_a MediaCloud::QueryParams
      expect(result.first.keywords).to eq 'foo'
      expect(result.first.media).to eq({ sets: [123], sources: [] })
      expect(result.first.start_date).to eq '2017-01-01'
      expect(result.first.end_date).to eq '2017-01-03'
      expect(result.first.meta).to eq({ name: 'Foo', color: 'e14c11' })

      expect(result.last).to be_a MediaCloud::QueryParams
      expect(result.last.keywords).to eq 'bar í'
      expect(result.last.media).to eq({ sets: [456], sources: [] })
      expect(result.last.start_date).to eq '2017-01-02'
      expect(result.last.end_date).to eq '2017-01-04'
      expect(result.last.meta).to eq({ name: 'Bar', color: '20b1b8' })
    end

    context 'invalid url' do
      it 'raises parse error' do
        url = 'https://explorer.mediacloud.org/#/queries/search?q=[foo]'
        expect { described_class.parse_url(url) }.to raise_error(MediaCloud::ParseError)

        url = 'https://explorer.mediacloud.org/#/queries/search'
        expect { described_class.parse_url(url) }.to raise_error(MediaCloud::ParseError)
      end
    end

    context 'missing quote escapes' do
      let(:url) { 'https://explorer.mediacloud.org/#/queries/search?q=[{"label": " "Foo" ","q": ""foo"", "color": "%23e14c11", "startDate": "2017-01-01", "endDate": "2017-01-03", "sources": [], "collections": [123]}]' }

      it 'parses malformed JSON' do
        result = described_class.parse_url(url)
        expect(result.length).to eq 1

        expect(result.first).to be_a MediaCloud::QueryParams
        expect(result.first.keywords).to eq '"foo"'
        expect(result.first.media).to eq({ sets: [123], sources: [] })
        expect(result.first.start_date).to eq '2017-01-01'
        expect(result.first.end_date).to eq '2017-01-03'
        expect(result.first.meta).to eq({ name: ' "Foo" ', color: 'e14c11' })
      end
    end
  end

  describe described_class::QueryParams do
    let(:params) { described_class.new('foo', { sets: [123] }, '2017-1-01', '2017-1-02', { name: 'Foo' }) }

    describe '#name' do
      it { expect(params.name).to eq 'Foo' }
    end

    describe '#solr_q' do
      it { expect(params.solr_q).to eq 'sentence:foo' }
    end

    describe '#solr_fq' do
      it { expect(params.solr_fq).to eq '(tags_id_media:123) AND publish_date:[2017-01-01T00:00:00.000Z TO 2017-01-02T23:59:59.000Z]' }
    end
  end
end
