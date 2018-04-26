# == Schema Information
#
# Table name: collaborator_checklist_items
#
#  id                        :integer          not null, primary key
#  collaborator_checklist_id :integer          not null
#  project_checklist_item_id :integer          not null
#  checked                   :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_collaborator_checklist_items_checklist_id_item_id  (collaborator_checklist_id,project_checklist_item_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_14de27aa77  (project_checklist_item_id => project_checklist_items.id)
#  fk_rails_8e0a577c67  (collaborator_checklist_id => collaborator_checklists.id)
#

class CollaboratorChecklistItem < ApplicationRecord
  validates :collaborator_checklist, presence: true
  validates :project_checklist_item, presence: true

  belongs_to :collaborator_checklist
  belongs_to :project_checklist_item

  alias_attribute :checklist, :collaborator_checklist
  alias_attribute :list, :collaborator_checklist

  delegate :item, to: :project_checklist_item
  delegate :help, to: :project_checklist_item
  delegate :with_translation, to: :project_checklist_item
  delegate :with_translation_in_current_locale, to: :project_checklist_item
  delegate :item_with_translation_in_current_locale, to: :project_checklist_item
  delegate :help_with_translation_in_current_locale, to: :project_checklist_item


  def check!
    self.checked = true
    self.save!
  end

  def uncheck!
    self.checked = false
    self.save!
  end
  
end
