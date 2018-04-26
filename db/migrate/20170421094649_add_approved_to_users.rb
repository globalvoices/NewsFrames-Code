class AddApprovedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :approved, :boolean, default: false, null: false
    add_index :users, :approved
  end
end
