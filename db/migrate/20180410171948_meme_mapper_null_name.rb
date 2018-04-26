class MemeMapperNullName < ActiveRecord::Migration[5.0]
  def change
    change_column :meme_mappers, :name, :string, null: true
  end
end
