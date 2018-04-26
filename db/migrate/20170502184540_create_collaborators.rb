class CreateCollaborators < ActiveRecord::Migration[5.0]
  class Collaborator < ActiveRecord::Base; end
  class Project < ActiveRecord::Base; end

  def up
    create_table :collaborators do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.boolean :lead, null: false, default: false
      t.timestamps null: false
    end

    add_foreign_key :collaborators, :projects
    add_foreign_key :collaborators, :users

    Project.all.find_each do |project|
      collaborator = Collaborator.new
      collaborator.project_id = project.id
      collaborator.user_id = project.lead_id
      collaborator.lead = true
      collaborator.save!
    end

    remove_foreign_key :projects, :users
    remove_column :projects, :lead_id
  end

  def down
    add_column :users, :lead_id, :integer

    Collaborators.all.find_each do |collaborator|
      project = Project.find(collaborator.project_id)
      project.lead_id = collaborator.user_id
      project.save!
    end

    change_column :projects, :lead_id, :integer, null: false
    add_foreign_key :projects, :users

    drop_table :collaborators
  end
end
