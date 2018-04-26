class AddCheckedToProjectChecklistItems < ActiveRecord::Migration[5.0]
  class ProjectChecklistItem < ActiveRecord::Base
    self.table_name = 'project_checklist_items'
  end

  def change
    add_column :project_checklist_items, :checked, :boolean, default: false, null: false
    add_index :project_checklist_items, :checked

    ProjectChecklistItem.all.each do |entry|
      entry.checked = false
      entry.save!
    end
  end
end
