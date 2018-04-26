class AddPublicToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :public, :boolean, null: false, default: false
  end
end
