# == Schema Information
#
# Table name: project_checklist_items
#
#  id                   :integer          not null, primary key
#  project_checklist_id :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Foreign Keys
#
#  fk_rails_a3eb727366  (project_checklist_id => project_checklists.id)
#

class ProjectChecklistItem < ApplicationRecord

  validates :project_checklist, presence: true
  validates :item, presence: true

  belongs_to :project_checklist
  alias_attribute :list, :project_checklist

  has_many :collaborator_checklist_items, dependent: :destroy

  delegate :project, to: :list

  translates :item, :help

  globalize_accessors :locales => [:en_US], :attributes => [:item, :help]

  def check!
    self.checked = true
    self.save!
  end

  def uncheck!
    self.checked = false
    self.save!
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

  def with_translation_in_current_locale(fallback_locale='en_US')
    current_locale = I18n.locale.to_s
    with_translation(current_locale, fallback_locale)
  end

  def item_with_translation_in_current_locale(fallback_locale='en_US')
    attr_with_translation_in_current_locale(:item, fallback_locale)
  end

  def help_with_translation_in_current_locale(fallback_locale='en_US')
    attr_with_translation_in_current_locale(:help, fallback_locale)
  end

  private

  def attr_with_translation_in_current_locale(attrsym, fallback_locale)
    translation = with_translation_in_current_locale(fallback_locale)
    return nil unless translation.present?
    translation[attrsym]
  end

end
