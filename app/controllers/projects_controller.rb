class ProjectsController < ApplicationController
  include EtherpadConcern

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  helper_method :presenter

  def index
    authorize(Project)
    projects = policy_scope(Project.all)

    @public_projects = projects.where(public: true).order(:name)

    if current_user.present?
      @lead_projects = projects.collaborating(current_user).lead.order(:name)
      @shared_projects = projects.collaborating(current_user).nonlead.order(:name)
    end
  end

  def new
    @form = ProjectForm.new(project: Project.new, user: current_user)
    authorize(@form.project)
  end

  def create
    @form = ProjectForm.new(form_params(Project.new))
    authorize(@form.project)
    if @form.valid? && save_form
      redirect_to project_path(@form.project)
    else
      render :new
    end
  end

  def show
    @project = find_project
  end

  def edit
    project = find_project
    @form = ProjectForm.new(project: project, user: current_user)
  end

  def update
    project = find_project
    @form = ProjectForm.new(form_params(project))
    if @form.valid? && save_form
      redirect_to project_path(project)
    else
      render :edit
    end
  end

  def destroy
    Projects::Delete.(project: find_project)
    redirect_to projects_path
  end

  def pads
    @project = find_project
    start_etherpad_session(presenter.current_pad) if policy(@project).collaborate?
    respond_to(&:js)
  end

  def checklist_report
    @project = find_project
    csv = Projects::Checklists.(project: @project, format: :csv)    
    csv_file_name = "project-#{@project.name.parameterize}-checklists-report.csv"
    respond_to do |format|
      format.html { send_data csv, type: 'text/csv', filename: csv_file_name, disposition: :attachment.to_s }
    end
  end

  private

  def find_project
    project = Project.find(params[:project_id] || params[:id])
    authorize(project)
    project
  end

  def save_form
    @form.save!
    true
  rescue ActiveRecord::RecordInvalid => e
    @errors = e.record.errors if e.record.present?
    false
  end

  def form_params(project)
    params.require(:project).permit(*ProjectForm.permit).merge(project: project, user: current_user).to_h
  end

  def presenter
    @presenter ||= ProjectPresenter.new(find_project, params[:pad])
  end
end
