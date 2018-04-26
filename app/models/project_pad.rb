# == Schema Information
#
# Table name: project_pads
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  pad_id     :string           not null
#  name       :string           not null
#  index      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_project_pads_on_project_id_and_index   (project_id,index) UNIQUE
#  index_project_pads_on_project_id_and_pad_id  (project_id,pad_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_74936109d2  (project_id => projects.id)
#

class ProjectPad < ApplicationRecord
  belongs_to :project

  validates :name, presence: true
end
