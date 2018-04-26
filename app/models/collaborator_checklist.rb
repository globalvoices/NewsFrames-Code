# == Schema Information
#
# Table name: collaborator_checklists
#
#  id                   :integer          not null, primary key
#  collaborator_id      :integer          not null
#  project_checklist_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_collaborator_checklists_collaborator_id_proj_chklst_id  (collaborator_id,project_checklist_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_16b4d81ae0  (project_checklist_id => project_checklists.id)
#  fk_rails_e718fd0b8f  (collaborator_id => collaborators.id)
#

class CollaboratorChecklist < ApplicationRecord
  validates :collaborator, presence: true

  has_many :collaborator_checklist_items, dependent: :destroy
  belongs_to :collaborator
  belongs_to :project_checklist

  alias_attribute :items, :collaborator_checklist_items

  delegate :item, to: :project_checklist
  delegate :with_translation, to: :project_checklist
  delegate :with_translation_in_current_locale, to: :project_checklist

  def checked_items
    items.where(checked: true)
  end

  def progress
    return 0 unless items.present?
    checked_count.to_f / items.length * 100
  end

  def checked_count
    checked_items.count
  end

end
