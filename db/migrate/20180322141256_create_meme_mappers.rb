class CreateMemeMappers < ActiveRecord::Migration[5.0]
  def change
    create_table :meme_mappers do |t|
      t.integer :project_id, null: false
      t.string :name, null: false
      t.string :image_url, null: false
      t.binary :serialized_data, null: false, default: ''
      t.timestamps null: false
    end

    add_foreign_key :meme_mappers, :projects
  end
end
