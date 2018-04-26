class MediaCloudQuery
  class APIError < StandardError; end
  class TypeError < StandardError; end

  class QueryType < Struct.new(:media_cloud, :query_params)
    def self.endpoint(endpoint = nil)
      if endpoint.nil?
        @endpoint
      else
        @endpoint = endpoint
      end
    end

    def params
      {}
    end

    def full_params
      params
    end

    def perform(options = {})
      qs = if options[:full]
        full_params
      else
        params
      end

      qs.merge!(
        q: query_params.solr_q,
        fq: query_params.solr_fq)

      res = media_cloud.get(self.class.endpoint, qs)

      if res.code == 200
        res.parsed_response
      else
        raise APIError, res.body
      end
    end
  end

  class WordCount < QueryType
    # https://github.com/berkmancenter/mediacloud/blob/master/doc/api_2_0_spec/api_2_0_spec.md#apiv2wclist

    endpoint '/wc/list'

    def params
      {
        num_words: 500,
        sample_size: 1000
      }
    end
  end

  class SentenceCount < QueryType
    # https://github.com/berkmancenter/mediacloud/blob/master/doc/api_2_0_spec/api_2_0_spec.md#apiv2sentencescount

    endpoint '/senteces/count'

    def params
      {
        split: 1,
        split_start_date: query_params.start_date.strftime('%Y-%m-%d'),
        split_end_date: query_params.end_date.strftime('%Y-%m-%d')
      }
    end
  end

  class Stories < QueryType
    # https://github.com/berkmancenter/mediacloud/blob/master/doc/api_2_0_spec/api_2_0_spec.md#apiv2stories_publiclist

    endpoint '/stories_public/list'

    def full_params
      params.merge(rows: ENV['STORIES_FETCH_LIMIT'].to_i, last_processed_stories_id: @last_processed_stories_id)
    end

    def perform(options = {})
      return super if !options[:full]

      parsed_stories = []

      loop do
        parsed_response = super
        break if parsed_response.empty?

        parsed_stories.push(*parsed_response)
        @last_processed_stories_id = parsed_stories.last['processed_stories_id']

        break if parsed_stories.length >= ENV['STORIES_STORAGE_LIMIT'].to_i
      end

      parsed_stories

    end
  end

  class StoryCount < QueryType
    # https://github.com/berkmancenter/mediacloud/blob/master/doc/api_2_0_spec/api_2_0_spec.md#apiv2stories_publiccount

    endpoint '/stories_public/count'
  end

  QUERY_CLASSES = {
    wordcount: WordCount,
    sentencecount: SentenceCount,
    stories: Stories,
    storycount: StoryCount
  }

  attr_reader :query_params

  def initialize(query_params)
    @query_params = query_params
  end

  def media_cloud
    @media_cloud ||= MediaCloud.new(ENV['MEDIACLOUD_API_KEY'])
  end

  def build(type)
    query_class = QUERY_CLASSES[type.to_sym] || (raise TypeError, 'unsupported query type')
    query_class.new(media_cloud, query_params)
  end
end
