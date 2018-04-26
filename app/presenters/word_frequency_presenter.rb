class WordFrequencyPresenter
  class Term < Struct.new(:value, :count)
    def eql?(term)
      value == term.value
    end

    alias == eql?

    def hash
      value.hash
    end
  end

  class TermSet < Set
    def normalize_counts(steps = nil)
      return self unless present?

      min = map(&:count).min
      max = map(&:count).max
      range = max - min + 1
      steps ||= range

      map do |term|
        count = term.count - min
        count = count * (steps.to_f / range.to_f)
        Term.new(term.value, count)
      end
    end
  end

  attr_reader :terms_a, :terms_b

  def initialize(group_a, group_b)
    @terms_a = term_set(group_a)
    @terms_b = group_b.present? ? term_set(group_b) : TermSet.new([])
  end

  def left
    TermSet.new(terms_a - terms_b)
  end

  def both
    intersection = terms_a & terms_b
    TermSet.new(
      intersection.map do |term|
        # sum the counts
        count_a = terms_a.find { |t| t == term }.count
        count_b = terms_b.find { |t| t == term }.count
        Term.new(term.value, count_a + count_b)
      end
    )
  end

  def right
    TermSet.new(terms_b - terms_a)
  end

  private

  def term_set(list)
    TermSet.new(list.map(&:with_indifferent_access).map { |item| Term.new(item[:term], item[:count]) })
  end
end
