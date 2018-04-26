class CreateQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :queries do |t|
      t.integer :project_id, null: false
      t.string :media_cloud_url, null: false
      t.jsonb :data, null: false, default: {}
      t.timestamps null: false
    end

    add_foreign_key :queries, :projects
  end
end
