class AddMigratedToQueries < ActiveRecord::Migration[5.0]
  def change
    add_column :queries, :migrated, :boolean, null: false, default: false
  end
end
