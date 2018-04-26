class CreateProjectChecklists < ActiveRecord::Migration[5.0]
  def change
    create_table :project_checklists do |t|
      t.string :name, null: false
      t.integer :project_id, null: false
      t.integer :checklist_id
      t.timestamps null: false
    end

    add_index :project_checklists, [:project_id, :name], unique: true
    add_foreign_key :project_checklists, :projects
    add_foreign_key :project_checklists, :checklists
  end
end
