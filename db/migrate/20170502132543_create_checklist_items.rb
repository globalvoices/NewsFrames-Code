class CreateChecklistItems < ActiveRecord::Migration[5.0]
  def change
    create_table :checklist_items do |t|
      t.integer :checklist_id, null: false
      t.string :item, null: false
      t.string :help
      t.timestamps null: false
    end

    add_foreign_key :checklist_items, :checklists
    add_index :checklist_items, [:checklist_id, :item], unique: true
  end
end
