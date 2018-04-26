class RemoveNullConstraintFromUserName < ActiveRecord::Migration[5.0]
  def up
    change_column :users, :name, :string, null: true
  end

  def down
    change_column :users, :name, :string, null: false
  end
end
