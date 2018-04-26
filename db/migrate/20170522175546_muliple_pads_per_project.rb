class MuliplePadsPerProject < ActiveRecord::Migration[5.0]
  class Project < ActiveRecord::Base; end
  class ProjectPad < ActiveRecord::Base; end

  def up
    create_table :project_pads do |t|
      t.integer :project_id, null: false
      t.string :pad_id, null: false
      t.string :name, null: false
      t.integer :index, null: false
      t.timestamps null: false
    end

    add_foreign_key :project_pads, :projects
    add_index :project_pads, [:project_id, :pad_id], unique: true
    add_index :project_pads, [:project_id, :index], unique: true

    Project.all.find_each do |project|
      ProjectPad.create!(project_id: project.id, pad_id: project.pad_id, name: 'Notes', index: 0)
    end

    remove_column :projects, :pad_id
  end

  def down
    add_column :projects, :pad_id, :string

    Project.all.find_each do |project|
      pad = ProjectPad.where(project_id: project.id).order(:index).first
      project.pad_id = pad.pad_id
      project.save!
    end

    change_column :projects, :pad_id, :string, null: false
    drop_table :project_pads
  end
end
