class AddLanguageToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :language, :string, null: false, default: 'eng'
  end
end
