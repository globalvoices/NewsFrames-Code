# == Schema Information
#
# Table name: project_checklists
#
#  id           :integer          not null, primary key
#  project_id   :integer          not null
#  checklist_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_d413c47a9b  (checklist_id => checklists.id)
#  fk_rails_da4f143d9e  (project_id => projects.id)
#

class ProjectChecklist < ApplicationRecord

  validates :name, presence: true
  validates :project, presence: true

  has_many :project_checklist_items, dependent: :destroy
  belongs_to :project
  belongs_to :checklist
  has_many :collaborator_checklists, dependent: :destroy

  alias_attribute :items, :project_checklist_items
  alias_attribute :global_checklist, :checklist

  translates :name

  globalize_accessors :locales => [:eng], :attributes => [:name]

  def progress
    return 0 if item_count == 0
    checked_count.to_f / item_count * 100
  end

  def checked_count
    count = 0
    collaborator_checklists.each do |checklist|
      count = count + checklist.checked_count
    end
    count
  end

  def item_count
    return 0 unless project_checklist_items.present?
    project_checklist_items.count * project.collaborators.count
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end

  def with_translation(locale, fallback_locale = nil)
    model = self.translations.where(locale: locale).first
    return model if model.present?
    return nil unless fallback_locale.present?
    self.translations.where(locale: fallback_locale).first
  end

  def with_translation_in_current_locale(fallback_locale='eng')
    current_locale = ISO_639.find(I18n.locale.to_s).alpha3
    with_translation(current_locale, fallback_locale)
  end
end
