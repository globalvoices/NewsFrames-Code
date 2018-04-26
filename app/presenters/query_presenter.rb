class QueryPresenter < Struct.new(:query, :filter)
  delegate :query_params, to: :query

  def initialize(query, filter = nil)
    super(query, filter || {})
  end

  def query_url
    query.media_cloud_url
  end

  def query_colors
    query_params.map(&:color)
  end

  def query_names
    unnamed = 0
    query_params.map do |params|
      params.name || "Unnamed #{unnamed += 1}"
    end
  end

  def query_label
    query.name || query_names.join(', ')
  end

  def query_data(query_type)
    query.data[query_type]
  end

  # Word frequency widget

  def frequencies
    return @frequencies if @frequencies.present?

    results = query_data(:wordcount)
    results_a = results[frequency_indices.first]
    results_b = results[frequency_indices.last]
    @frequencies = WordFrequencyPresenter.new(results_a, results_b)
  end

  def frequency_params
    [query_params[frequency_indices.first], query_params[frequency_indices.last]]
  end

  def frequency_terms
    @frequency_terms ||= [:left, :both, :right].map do |set|
      normalized = frequencies.send(set).normalize_counts(20)
      sorted = normalized.sort_by { |term| [-term.count, term.value] }
      sorted.slice(0, 80)
    end
  end

  def frequency_options
    query_params.each_with_index.map do |params, i|
      [query_names[i], i]
    end
  end

  def frequency_indices
    if filter.present? && filter[:frequency].present?
      filter[:frequency].map(&:to_i).slice(0, 2)
    else
      # first 2 by default
      [0, 1]
    end
  end

  # CSV

  def render_csv
    CSV.generate(force_quotes: true) do |csv|
      if filter[:frequency].present?
        csv << ['term', 'stem', 'count']

        query.data[:wordcount][filter[:frequency].to_i].each do |item|
          csv << [item['term'], item['stem'], item['count']]
        end
      elsif filter[:stories].present?
        csv << ['stories_id', 'language', 'title', 'publish_date', 'url']
        query.data[:stories][filter[:stories].to_i].each do |item|
          csv << [
            item['stories_id'],
            item['language'],
            item['title'],
            item['publish_date'],
            item['url']
          ]
        end
      end
    end
  end
end
