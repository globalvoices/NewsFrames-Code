class ChecklistsController < ApplicationController
  after_action :verify_authorized

  helper_method :checklists_form, :collaborator, :project

  def policy_class
    CollaboratorChecklistPolicy
  end

  def index
    authorize(CollaboratorChecklist.new(collaborator: collaborator), :index?)
    checklists_form
    respond_to(&:js)
  end

  def check
    authorize(CollaboratorChecklist.new(collaborator: collaborator), :check_item?)
    @checklists_form = ProjectChecklistsForm.new(form_params(collaborator))
    @errors = @checklists_form.errors unless @checklists_form.valid?
    @checklists_form.save!
  rescue ActiveRecord::RecordInvalid => e
    @errors = e.record.errors
  ensure
    respond_to(&:js)
  end

  private

  def form_params(collaborator)
    params.require(:collaborator_checklist).permit(*ProjectChecklistsForm.permit).merge(collaborator: collaborator, user: current_user).to_h
  end

  def checklists_form
    @checklists_form ||= ProjectChecklistsForm.new(collaborator: collaborator) if collaborator.present?
  end

  def project
    @project ||= Project.find(params[:project_id])
  end

  def collaborator
    @collaborator ||= Collaborator.find_by(project_id: params[:project_id], user_id: current_user.id)
  end
end
