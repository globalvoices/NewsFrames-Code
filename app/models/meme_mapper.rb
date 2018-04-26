# == Schema Information
#
# Table name: meme_mappers
#
#  id              :integer          not null, primary key
#  project_id      :integer          not null
#  name            :string
#  image_url       :string           not null
#  serialized_data :binary           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Foreign Keys
#
#  fk_rails_0b67925060  (project_id => projects.id)
#

class MemeMapper < ApplicationRecord
  belongs_to :project

  validates :image_url, presence: true

  def data
    @data ||= JSON.parse(ActiveSupport::Gzip.decompress(self.serialized_data))
  end

  def data=(data)
    json = data.to_json
    @data = JSON.parse(json) # make sure data is always access with the same encoding
    self.serialized_data = ActiveSupport::Gzip.compress(json)
  end
end
