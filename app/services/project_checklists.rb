module ProjectChecklists

  class Associate
    def self.call(params)
      checklists = params[:checklists]
      checklists = [] unless checklists.present?

      zombie_checklists = params[:zombie_checklists]
      zombie_checklists = [] unless zombie_checklists.present?

      project = params[:project]
      raise ArgumentError, 'missing project' unless project.present?

      ActiveRecord::Base.transaction do
        checklists.each do |chklst|
          unless project.has_checklist?(chklst)
            ProjectChecklists::Create.(project: project, checklist: chklst)
          end
        end

        project.checklists.each do |chklst|
          unless checklists.any? { |entry| entry == chklst.global_checklist } or
                 zombie_checklists.any? { |entry| entry == chklst }
            ProjectChecklists::Destroy.(project: project, checklist: chklst)
          end
        end
      end
    end
  end

  class Create
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      project = params[:project]
      raise ArgumentError, 'missing project' unless project.present?

      return if project.has_checklist?(checklist)

      project_checklist = nil
      project_checklist_items = []
      ActiveRecord::Base.transaction do

        Globalize.with_locale :eng do
          project_checklist = ProjectChecklist.new(name: checklist.name,
                                                   project: project,
                                                   checklist: checklist)
          project_checklist.save!

          checklist.items.each do |entry|
            item = ProjectChecklistItem.new(item: entry.item,
                                            help: entry.help,
                                            project_checklist: project_checklist)
            item.save!
            project_checklist_items.push(item)
          end
        end

        checklist.available_translations.each do |language|
          Globalize.with_locale language do
            project_checklist.name = checklist.name
            project_checklist.save!

            checklist.items.each_with_index do |entry, index|
              project_checklist_items[index].item = entry.item
              project_checklist_items[index].help = entry.help
              project_checklist_items[index].save!
            end
          end
        end

        project.collaborators.each do |collaborator|
          CollaboratorChecklists::Create.(collaborator: collaborator, checklist: project_checklist)
        end

        project_checklist.reload
      end
      project_checklist
    end
  end

  class Destroy
    def self.call(params)
      checklist = params[:checklist]
      raise ArgumentError, 'missing checklist' unless checklist.present?

      project = params[:project]
      raise ArgumentError, 'missing project' unless project.present?

      return unless checklist.project == project

      ActiveRecord::Base.transaction do
        checklist.destroy!
      end
    end
  end
  
end