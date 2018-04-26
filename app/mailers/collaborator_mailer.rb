class CollaboratorMailer < ApplicationMailer
  def created(collaborator_id, invitation_token = nil)
    @collaborator = Collaborator.find(collaborator_id)
    @user = @collaborator.user
    @project = @collaborator.project
    @invitation_token = invitation_token
    mail(to: @user.email, subject: "You were added as a collaborator to #{@collaborator.project.name}")
  end
end
