module Checklists

  class Create

    def self.call(params)
      name = params[:name]
      raise ArgumentError, 'missing name' unless name.present?

      items = params[:items]
      raise ArgumentError, 'missing items' unless items.present?

      checklist = nil
      ActiveRecord::Base.transaction do

        Globalize.with_locale :en_US do
          checklist = Checklist.new(name: name)
          checklist.save!

          items.each do |entry|
            checklist_item = ChecklistItem.new(checklist_id: checklist.id,
                                               item: entry[:item],
                                               help: entry[:help])
            checklist_item.save!
          end
        end

      end
      checklist
    end
  end

  class Update
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      name = params[:name]
      raise ArgumentError, 'missing name' unless name.present?

      Globalize.with_locale :en_US do
        checklist.name = name
        checklist.save!
      end

      checklist.reload
    end
  end

  class AddTranslation
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      localized_items = params[:items]
      raise ArgumentError, 'missing items' unless localized_items.present?

      localized_name = params[:name]
      raise ArgumentError, 'missing name' unless localized_name.present?

      language = params[:language]
      raise ArgumentError, 'missing language' unless language.present?

      raise ServiceError, 'Item count does not match in translation' unless checklist.items.length == localized_items.length
      raise ServiceError, 'Checklist already translated in this language' if checklist.with_translation(language).present?

      ActiveRecord::Base.transaction do

        Globalize.with_locale language do
          checklist.name = localized_name
          checklist.save!

          checklist.items.each_with_index do |checklist_item, index|
            checklist_item.item = localized_items[index][:item]
            checklist_item.help = localized_items[index][:help]
            checklist_item.save!
          end
        end

      end
      checklist
    end
  end

  class UpdateTranslation
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      language = params[:language]
      raise ArgumentError, 'missing language' unless language.present?

      name = params[:name]
      raise ArgumentError, 'missing name' unless name.present?

      raise ServiceError, 'Translation does not exist in this language' unless checklist.available_translations.include?(language.to_sym)

      Globalize.with_locale language do
        checklist.name = name
        checklist.save!
      end
      checklist.reload
    end
  end

  class RemoveTranslation
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      language = params[:language]
      raise ArgumentError, 'missing language' unless language.present?

      raise ServiceError, 'Translation does not exist in this language' unless checklist.available_translations.include?(language.to_sym)

      ActiveRecord::Base.transaction do
        checklist.items.each do |entry|
          entry.with_translation(language).destroy
        end
        checklist.with_translation(language).destroy
      end
    end
  end

  class Enable
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      return checklist if checklist.enabled?

      Globalize.with_locale :en_US do
        checklist.enabled = true
        checklist.save!
      end
    end
  end

  class Disable
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      return checklist unless checklist.enabled?

      Globalize.with_locale :en_US do
        checklist.enabled = false
        checklist.save!
      end
    end
  end
end
