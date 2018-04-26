class ProjectPadsController < ApplicationController
  include EtherpadConcern

  before_action :authorize_project
  after_action :verify_authorized

  helper_method :project, :project_presenter

  def new
    @project_pad = ProjectPad.new(project: project)
    authorize(@project_pad)
    respond_to(&:js)
  end

  def create
    @project_pad = ProjectPad.new(project_pad_params)
    authorize(@project_pad)

    Projects::SavePad.(project_pad: @project_pad)
    start_etherpad_session(@project_pad) if policy(project).collaborate?
  rescue ActiveRecord::RecordInvalid
  ensure
    respond_to(&:js)
  end

  def edit
    @project_pad = ProjectPad.find(params[:id])
    authorize(@project_pad)
    respond_to(&:js)
  end

  def update
    @project_pad = ProjectPad.find(params[:id])
    @project_pad.attributes = project_pad_params
    authorize(@project_pad)

    Projects::SavePad.(project_pad: @project_pad)
  rescue ActiveRecord::RecordInvalid
  ensure
    respond_to(&:js)
  end

  def destroy
    project_pad = ProjectPad.find(params[:id])
    authorize(project_pad)
    Projects::DeletePad.(project_pad: project_pad)

    @project_pad = project_presenter.primary_pad
    start_etherpad_session(@project_pad) if policy(project).collaborate?
    respond_to(&:js)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def project_presenter(pad_id = nil)
    @project_presenter ||= ProjectPresenter.new(project, pad_id)
  end

  def authorize_project
    authorize(project, :show?)
  end

  def project_pad_params
    params.require(:project_pad).permit(:name).merge(project: project)
  end
end
