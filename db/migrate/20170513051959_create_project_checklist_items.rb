class CreateProjectChecklistItems < ActiveRecord::Migration[5.0]
  def change
    create_table :project_checklist_items do |t|
      t.integer :project_checklist_id, null: false
      t.string :item, null: false
      t.string :help
      t.timestamps null: false
    end

    add_foreign_key :project_checklist_items, :project_checklists
    add_index :project_checklist_items, [:project_checklist_id, :item], unique: true
  end
end
