require 'httparty'

class MediaCloud
  include HTTParty
  base_uri ENV['MEDIACLOUD_API_URL']

  class ParseError < StandardError; end

  class QueryParams < Struct.new(:keywords, :media, :start_date, :end_date, :meta)
    SOLR_DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.000Z'

    def name
      meta[:name]
    end

    def color
      meta[:color]
    end

    def sources
      if media['sets'].present?
        [media['sets'].length, 'collection']
      elsif media['sources'].present?
        [media['sources'].length, 'source']
      else
        []
      end
    end

    def start_date
      DateTime.parse(super)
    end

    def end_date
      DateTime.parse(super)
    end

    def solr_q
      keywords
    end

    def solr_fq
      tags = []

      (media[:sets] || []).each do |set|
        tags << "tags_id_media:#{set}"
      end

      (media[:sources] || []).each do |source|
        tags << "media_id:#{source}"
      end

      parts = []
      if tags.present?
        parts << "(#{tags.join(' OR ')})"
      end

      start_time = start_date.strftime(SOLR_DATE_FORMAT)
      end_time = end_date.end_of_day.strftime(SOLR_DATE_FORMAT)
      parts << "publish_date:[#{start_time} TO #{end_time}]"
      parts.join(' AND ')
    end
  end

  def self.parse_url(url)
    fragment = url.split('#').last
    uri = URI.parse(URI.encode(fragment))
    qs = Rack::Utils.parse_nested_query(uri.query)
    if qs['q'].present?
      q = URI.unescape(qs['q'])
      parsed = begin
        JSON.parse(q)
      rescue JSON::ParserError => e
        q = fix_unescaped_quotes(q)
        JSON.parse(q)
      end
      parsed.map do |params|
        QueryParams.new(
          params['q'],
          {
            sources: params['sources'],
            sets: params['collections']
          },
          params['startDate'],
          params['endDate'],
          {
            name: params['label'],
            color: params['color'].gsub('#', '')
          }
        )
      end
    else
      raise ParseError
    end
  rescue JSON::ParserError
    raise ParseError
  end

  def initialize(api_key)
    @api_key = api_key
  end

  def get(path, query = {})
    query[:key] ||= @api_key
    self.class.get(path, { query: query })
  end

  private

  def self.fix_unescaped_quotes(str)
    # Noticed that some MC queries contained malformed JSON (unescaped quotes)
    # i.e. { "foo": ""bar"" } instead of { "foo": "\"bar\"" }
    # This tries to workaround that until it is fixed in MC
    str
      .gsub(/:(\s*)\"(\s*)\"/) { ":#{$1}\"#{$2}\\\"" }
      .gsub(/\"(\s*)\"(\s*),/) { "\\\"#{$1}\"#{$2}," }
  end
end
