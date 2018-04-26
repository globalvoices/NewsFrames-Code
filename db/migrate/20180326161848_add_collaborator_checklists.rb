class AddCollaboratorChecklists < ActiveRecord::Migration[5.0]
  def change
    create_table :collaborator_checklists do |t|
      t.integer :collaborator_id, null: false
      t.integer :project_checklist_id
      t.timestamps null: false
    end

    add_index :collaborator_checklists, [:collaborator_id, :project_checklist_id], unique: true, name: 'index_collaborator_checklists_collaborator_id_proj_chklst_id'
    add_foreign_key :collaborator_checklists, :collaborators
    add_foreign_key :collaborator_checklists, :project_checklists
  end
end
