# == Schema Information
#
# Table name: checklist_items
#
#  id           :integer          not null, primary key
#  checklist_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_3605ca8e4d  (checklist_id => checklists.id)
#

class ChecklistItem < ApplicationRecord

  validates :checklist, presence: true
  validates :item, presence: true, uniqueness: { case_sensitive: false, scope: :checklist_id }

  belongs_to :checklist
  alias_attribute :list, :checklist

  translates :item, :help

  globalize_accessors :locales => [:eng], :attributes => [:item, :help]

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
