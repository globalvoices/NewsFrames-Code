# == Schema Information
#
# Table name: queries
#
#  id              :integer          not null, primary key
#  project_id      :integer          not null
#  media_cloud_url :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  name            :string
#  full_data       :boolean          default(FALSE), not null
#  serialized_data :binary
#  migrated        :boolean          default(FALSE), not null
#
# Foreign Keys
#
#  fk_rails_177ec16807  (project_id => projects.id)
#

class Query < ApplicationRecord
  QUERY_TYPES = [:storycount, :wordcount, :stories]

  attr_reader :term

  belongs_to :project

  validates :media_cloud_url, presence: true

  def term=(value)
    value = value.strip
    if value =~ /^http/
      self.media_cloud_url = value
    else
      start_date = (Date.today - 1.year).to_s
      end_date = Date.today.to_s
      q = [{
        'label' => value,
        'q' => value,
        'startDate' => start_date,
        'endDate' => end_date,
        'sources' => [],
        'collections' => [9139487],
        'color' => '%23000000'
      }]
      self.media_cloud_url = "https://explorer.mediacloud.org/#/queries/search?q=#{q.to_json}"
    end
  end

  def data
    @data ||= JSON.parse(ActiveSupport::Gzip.decompress(self.serialized_data)).with_indifferent_access
  end

  def data=(data)
    @data = data
    self.serialized_data = ActiveSupport::Gzip.compress(JSON.dump(data))
  end

  def query_params
    @query_params ||= MediaCloud.parse_url(media_cloud_url)
  end
end
