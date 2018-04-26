class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :lead_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :projects, :users, column: :lead_id
  end
end
