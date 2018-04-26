# == Schema Information
#
# Table name: checklists
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  enabled    :boolean          default(TRUE), not null
#

class Checklist < ApplicationRecord

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :checklist_items, dependent: :destroy
  has_many :project_checklists, dependent: :nullify
  alias_attribute :items, :checklist_items

  translates :name
  globalize_accessors :locales => [:eng], :attributes => [:name]

  def cache_key
    super + '-' + Globalize.locale.to_s
  end

  def available_translations
    self.translations.map(&:locale).reject { |entry| entry == :eng || entry == :en }
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
