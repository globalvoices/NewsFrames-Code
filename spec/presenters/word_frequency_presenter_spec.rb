require 'rails_helper'

describe WordFrequencyPresenter do
  let(:words_a) { [{ count: 5, term: 'foo' }, { count: 4, term: 'bar' }, { count: 3, term: 'baz' }] }
  let(:words_b) { [{ count: 5, term: 'bar' }, { count: 4, term: 'baz' }, { count: 3, term: 'qux' }] }

  let(:presenter) { WordFrequencyPresenter.new(words_a, words_b) }

  describe '#left' do
    it { expect(presenter.left.map(&:value)).to eq ['foo'] }
    it { expect(presenter.left.map(&:count)).to eq [5] }
  end

  describe '#both' do
    it { expect(presenter.both.map(&:value)).to eq ['bar', 'baz'] }
    it { expect(presenter.both.map(&:count)).to eq [9, 7] }
  end

  describe '#right' do
    it { expect(presenter.right.map(&:value)).to eq ['qux'] }
    it { expect(presenter.right.map(&:count)).to eq [3] }
  end

  describe described_class::TermSet do
    let(:term_set) do
      described_class.new(
        [
          WordFrequencyPresenter::Term.new('foo', 10),
          WordFrequencyPresenter::Term.new('bar', 4),
          WordFrequencyPresenter::Term.new('baz', 2)
        ]
      )
    end

    describe '#normalize_counts' do
      it 'normalizes count values so min equals 0' do
        expect(term_set.normalize_counts.map(&:count)).to eq [8, 2, 0]
      end

      it 'normalizes values into the given number of steps' do
        expect(term_set.normalize_counts(2).map(&:count)).to eq [1.7777777777777777, 0.4444444444444444, 0.0]
      end
    end
  end
end
