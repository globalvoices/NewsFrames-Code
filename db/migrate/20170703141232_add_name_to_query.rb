class AddNameToQuery < ActiveRecord::Migration[5.0]
  def change
    add_column :queries, :name, :string
  end
end
