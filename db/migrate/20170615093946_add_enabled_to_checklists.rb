class AddEnabledToChecklists < ActiveRecord::Migration[5.0]
  def change
    add_column :checklists, :enabled, :boolean, null: false, default: true
  end
end