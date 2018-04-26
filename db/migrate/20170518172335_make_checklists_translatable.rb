class MakeChecklistsTranslatable < ActiveRecord::Migration[5.0]

  class Checklist < ActiveRecord::Base
    self.table_name = 'checklists'
    translates :name
  end
  class ChecklistItem < ActiveRecord::Base
    self.table_name = 'checklist_items'
    translates :item, :help
  end
  class ProjectChecklist < ActiveRecord::Base
    self.table_name = 'project_checklists'
    translates :name
  end
  class ProjectChecklistItem < ActiveRecord::Base
    self.table_name = 'project_checklist_items'
    translates :item, :help
  end
  
  def up
    Checklist.create_translation_table!({ name: :string }, { migrate_data: true, remove_source_columns: true })
    ChecklistItem.create_translation_table!({ item: :string, help: :string}, { migrate_data: true, remove_source_columns: true })
    ProjectChecklist.create_translation_table!({ name: :string }, { migrate_data: true, remove_source_columns: true })
    ProjectChecklistItem.create_translation_table!({ item: :string, help: :string}, { migrate_data: true, remove_source_columns: true })
  end

  def down
    Checklist.drop_translation_table! migrate_data: true
    ChecklistItem.drop_translation_table! migrate_data: true
    ProjectChecklist.drop_translation_table! migrate_data: true
    ProjectChecklistItem.drop_translation_table! migrate_data: true
  end
end
