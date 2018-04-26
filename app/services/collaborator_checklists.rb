module CollaboratorChecklists
  class Create

    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      collaborator = params[:collaborator]
      raise ArgumentError, 'missing collaborator' unless collaborator.present?

      raise StandardError.new('Project mismatch') unless checklist.project_id == collaborator.project_id

      items = checklist.items

      new_checklist = nil
      ActiveRecord::Base.transaction do
        new_checklist = CollaboratorChecklist.create!(collaborator: collaborator, project_checklist: checklist)
        items.each do |item|
          CollaboratorChecklistItem.create!(collaborator_checklist: new_checklist, project_checklist_item: item)
        end
        new_checklist.reload
      end

      new_checklist
      
    end
  end

  class Destroy

    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      ActiveRecord::Base.transaction do
        checklist.destroy
      end
      
    end
  end

  class CheckItems
    def self.call(params)
      checklist_items = params[:checklist_items]
      checklist_items = [] unless checklist_items.present?

      collaborator = params[:collaborator]
      raise ArgumentError, 'missing collaborator' unless collaborator.present?

      ActiveRecord::Base.transaction do

        Globalize.with_locale :eng do
        
          checklist_items.each do |item|
            raise ArgumentError, 'invalid project or checklist item' unless item.project_checklist_item.project == collaborator.project
            item.check!
          end

          collaborator.reload

          collaborator.checklists.each do |checklist|
            checklist.checked_items.each do |item|
              unless checklist_items.include?(item)
                item.uncheck!
              end
            end
          end

        end
        
      end
    end
  end
end