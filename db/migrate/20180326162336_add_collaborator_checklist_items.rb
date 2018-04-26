class AddCollaboratorChecklistItems < ActiveRecord::Migration[5.0]
  def change
    create_table :collaborator_checklist_items do |t|
      t.integer :collaborator_checklist_id, null: false
      t.integer :project_checklist_item_id, null: false
      t.boolean :checked, default: false, null: false
      t.timestamps null: false
    end

    add_foreign_key :collaborator_checklist_items, :collaborator_checklists
    add_foreign_key :collaborator_checklist_items, :project_checklist_items
    add_index :collaborator_checklist_items, [:collaborator_checklist_id, :project_checklist_item_id], unique: true, name: 'index_collaborator_checklist_items_checklist_id_item_id'
  end
end
