class RemoveCheckedFromProjectChecklistItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :project_checklist_items, :checked, :boolean
  end
end
