class MemeMapperPresenter < Struct.new(:meme_mapper)
  class Backlink < Struct.new(:image_url, :date, :link); end
  class Match < Struct.new(:image_url, :backlinks); end

  BACKLINK_LIMIT = 5

  delegate :image_url, to: :meme_mapper

  def result_count
    data_value('table.stats.table.total_results')
  end

  def backlinks(page = 1)
    @backlinks ||= begin
      data_value('table.matches').map do |match|
        backlinks = data_value('table.backlinks', match).map do |data|
          Backlink.new(
            data_value('table.url', data),
            Date.parse(data_value('table.crawl_date', data)),
            data_value('table.backlink', data))
        end[0, BACKLINK_LIMIT]

        Match.new(match['table']['image_url'], backlinks)
      end
    end
  end

  private

  def data_value(path, value = nil)
    value = value || meme_mapper.data
    path.split('.').each { |key| value = value[key] }
    value
  end
end
