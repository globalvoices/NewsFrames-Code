class CopyProjectChecklistsToCollaborators < ActiveRecord::Migration[5.0]
  
  def up
    ActiveRecord::Base.transaction do
      
      ProjectChecklist.find_each do |checklist|
        
        items = checklist.project_checklist_items
        project = checklist.project

        project.collaborators.each do |collaborator|
          new_checklist = CollaboratorChecklist.create!(collaborator: collaborator, project_checklist: checklist)
          items.each do |item|
            new_item = CollaboratorChecklistItem.create!(collaborator_checklist: new_checklist, project_checklist_item: item)
            new_item.check! if item.checked
          end
        end

      end

    end
  end

  def down
    ActiveRecord::Base.transaction do
      CollaboratorChecklist.destroy_all
    end
  end
end
