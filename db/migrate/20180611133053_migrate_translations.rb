class MigrateTranslations < ActiveRecord::Migration[5.0]
  TRANSLATION_TABLES = [
    'checklist_translations',
    'checklist_item_translations',
    'project_checklist_translations',
    'project_checklist_item_translations'
  ]

  def up
    TRANSLATION_TABLES.each do |table|
      execute "UPDATE #{table} SET locale = 'en_US' WHERE locale = 'eng'"
      execute "UPDATE #{table} SET locale = 'es' WHERE locale = 'spa'"
      execute "UPDATE #{table} SET locale = 'es' WHERE locale = 'arr'"
    end

    change_column :users, :language, :string, null: false, default: 'en_US'
  end

  def down
    TRANSLATION_TABLES.each do |table|
      execute "UPDATE #{table} SET locale = 'eng' WHERE locale = 'en_US'"
      execute "UPDATE #{table} SET locale = 'spa' WHERE locale = 'es'"
    end

    change_column :users, :language, :string, null: false, default: 'eng'
  end
end
