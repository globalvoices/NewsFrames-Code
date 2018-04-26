class CollaboratorsController < ApplicationController
  before_action :authorize_project
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  helper_method :collaborator, :collaborators, :project

  def index
    authorize(Collaborator)
    collaborators # force scoping
    respond_to(&:js)
  end

  def invite
    authorize(Collaborator.new(project: project), :create?)

    emails = emails_param.reject { |item| item.blank? }

    users_hash = Users::FindByEmails.(emails: emails)
    found_count = users_hash.count { |item| item[:user].present? }

    unless found_count == users_hash.count or CollaboratorPolicy.new(current_user, Collaborator.new(project: project)).create_external?
      raise ExternalInvitePolicyError.new("not allowed to invite external users to collaborate")
    end

    Collaborators::Invite.(users_hash: users_hash, project: project)
  rescue ExternalInvitePolicyError => e
    @errors = [e]
  rescue ActiveRecord::RecordInvalid => e
    @errors = e.record.errors
  ensure
    respond_to(&:js)
  end

  def promote
    authorize(collaborator)
    Collaborators::Promote.(collaborator: collaborator)
    respond_to(&:js)
  end

  def destroy
    authorize(collaborator)
    Collaborators::Delete.(collaborator: collaborator)
    respond_to(&:js)
  end

  def suggest
    users = User.where('users.email NOT IN (?)', project.users.map(&:email))
    users = users.where('users.email ILIKE ?', "%#{params[:q]}%") if params[:q].present?

    render json: { emails: users.limit(10).map(&:email) }
  end

  private

  def emails_param
    params[:emails].split(/\,|\s+/) || []
  end

  def collaborators
    @collaborators ||= policy_scope(project.collaborators)
  end

  def collaborator
    @collaborator ||= Collaborator.find(params[:id])
  end

  def project
    @project ||= Project.find(params[:project_id])
  end

  # callbacks

  def authorize_project
    authorize(project, :show?)
  end

  class ExternalInvitePolicyError < StandardError
    def initialize(message)
      super
    end
  end

end
