module Collaborators
  class Invite
    def self.call(params)
      users_hash = params[:users_hash]
      raise ArgumentError, 'missing users_hash' unless users_hash.present?

      project = params[:project]
      raise ArgumentError, 'missing project' unless project.present?

      ActiveRecord::Base.transaction do
        users_hash.each do |item|
          
          user = item[:user]
          unless user.present?
            user = Invites::Create.(email: item[:email], skip_email: true)
            Users::Approve.(user: user, skip_email: true)
          end

          collaborator = Collaborator.find_or_initialize_by(project: project, user: user)

          if collaborator.new_record?
            collaborator.save!
            CollaboratorMailer.created(collaborator.id, user.raw_invitation_token).deliver_now
          end

          project.checklists.each do |project_checklist|
            CollaboratorChecklists::Create.(collaborator: collaborator, checklist: project_checklist)
          end

          collaborator
        end
      end
    end
  end

  class Promote
    def self.call(params)
      collaborator = params[:collaborator]
      raise ArgumentError, 'missing collaborator' unless collaborator.present?

      ActiveRecord::Base.transaction do
        collaborator.project.collaborators.update_all(lead: false)
        collaborator.lead = true
        collaborator.save!
      end
    end
  end

  class Delete
    def self.call(params)
      collaborator = params[:collaborator]
      raise ArgumentError, 'missing collaborator' unless collaborator.present?

      collaborator.destroy
    end
  end
end
