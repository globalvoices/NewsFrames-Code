module Projects
  class Save
    def self.call(params)
      project = params[:project]
      raise ArgumentError, 'missing project' unless project.present?

      ActiveRecord::Base.transaction do
        project.save!

        unless project.project_pads.present?
          project_pad = ProjectPad.new(project: project, name: 'Notes')
          Projects::SavePad.(project_pad: project_pad)
        end

        lead = params[:lead]
        if lead.present?
          collaborator = Collaborator.find_or_initialize_by(project: project, user: lead)
          collaborator.lead = true
          collaborator.save!
        end

        project
      end
    end
  end

  class SavePad
    def self.call(params)
      project_pad = params[:project_pad]
      raise ArgumentError, 'missing project_pad' unless project_pad.present?

      ActiveRecord::Base.transaction do
        unless project_pad.pad_id.present?
          pad = Etherpad::CreatePad.(name: SecureRandom.uuid)
          project_pad.pad_id = pad.id
        end

        unless project_pad.index.present?
          indexes = project_pad.project.project_pads.map(&:index)
          project_pad.index = (indexes.max || -1) + 1
        end

        project_pad.save!
      end
    end
  end

  class DeletePad
    def self.call(params)
      project_pad = params[:project_pad]
      raise ArgumentError, 'missing project_pad' unless project_pad.present?

      ActiveRecord::Base.transaction do
        project_pad.destroy

        Etherpad::DeletePad.(pad_id: project_pad.pad_id)
      end
    end
  end

  class Delete
    def self.call(params)
      project = params[:project]
      raise ArgumentError, 'missing project' unless project.present?

      ActiveRecord::Base.transaction do
        pad_ids = project.project_pads.map(&:pad_id)
        project.destroy

        pad_ids.each do |pad_id|
          Etherpad::DeletePad.(pad_id: pad_id)
        end
      end
    end
  end

  class Checklists

    def self.call(params)
      project = params[:project]
      raise ArgumentError, 'missing project' unless project.present?

      format = params[:format]
      raise ArgumentError, 'missing format' unless format.present?

      raise ArgumentError, 'invalid format' unless format.to_sym == :csv

      checklists_csv(project)
    end

    private

    def self.checklists_csv(project)

      Globalize.with_locale :en_US do
        CSV.generate(force_quotes: true) do |csv|
          csv << ["collaborator", "checklist", "item", "checked"]
          project.checklists.each do |project_checklist|
            project_checklist.collaborator_checklists.each do |chklst|
              collaborator = chklst.collaborator.user.display_name
              chklst.items.each do |chklst_item|
                csv << [collaborator, project_checklist.name, chklst_item.item, chklst_item.checked ? 'Y' : '']
              end
            end
          end
        end
      end

    end
  end

end
