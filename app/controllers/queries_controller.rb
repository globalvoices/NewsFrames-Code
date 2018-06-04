class QueriesController < ApplicationController
  helper_method :filter, :presenter, :project, :query
  before_action -> { authorize(project, :collaborate?) }

  def index
    @queries = project.queries.sort_by do |query|
      [
        QueryPresenter.new(query).query_label.gsub('"', '').downcase,
        -query.created_at.to_i
      ]
    end
    respond_to(&:js)
  end

  def new
    @query = Query.new(project: project)
    respond_to(&:js)
  end

  def create
    @query = Query.new(query_params)
    Queries::Save.(query: @query, fetch_data: true)
    redirect_to project_query_path(project, @query)
  rescue ActiveRecord::RecordInvalid
    render_error
  rescue MediaCloud::ParseError
    render_error('^Unable to parse URL')
  rescue Net::ReadTimeout
    render_error('^Query timeout. Please try using Media Cloud directly')
  rescue MediaCloudQuery::APIError
    puts err
    Rollbar.error(err)
    render_error('^Media Cloud not responding')
  rescue Exception => err
    Rollbar.error(err)
    Rails.logger.error(err)
    render_error('^Unexpected error')
  end

  def show
    respond_to do |format|
      format.js
      format.csv do
        begin
          Queries::DownloadFullData.(query: query)
          send_data(presenter.render_csv, type: 'text/csv', filename: csv_file_name, disposition: :attachment.to_s)
        rescue MediaCloudQuery::APIError
          puts err
          Rollbar.error(err)
          flash[:error] = 'Media Cloud not responding'
          redirect_to project_path(project)
        end
      end
    end
  end

  def edit
  end

  def update
    query.update_attributes(query_params)
    Queries::Save.(query: query, fetch_data: false)
    redirect_to project_query_path(project, query)
  rescue ActiveRecord::RecordInvalid
    render :edit
    respond_to(&:js)
  end

  def destroy
    query.destroy!
    respond_to(&:js)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def query
    @query ||= Query.find(params[:id])
  end

  def query_params
    params.require(:query).permit(:name, :term).merge(project: project)
  end

  def filter
    params[:filter]
  end

  def presenter
    @presenter ||= QueryPresenter.new(query, filter)
  end

  def csv_file_name
    filterName = filter[:frequency].present? ? :frequency.to_s : :stories.to_s
    "#{project.name}-#{query.name}-#{DateTime.now}-#{filterName}.csv"
  end

  def render_error(error = '')
    @query.errors.add(:media_cloud_url, error) if error.present?
    render :new
    respond_to(&:js)
  end
end
