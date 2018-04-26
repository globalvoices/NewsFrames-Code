class MemeMappersController < ApplicationController
  helper_method :project, :meme_mapper, :presenter
  before_action -> { authorize(project, :collaborate?) }

  def index
    @meme_mappers = project.meme_mappers.order('created_at DESC')
    respond_to(&:js)
  end

  def new
    @meme_mapper = MemeMapper.new(project: project)
    respond_to(&:js)
  end

  def create
    @meme_mapper = MemeMapper.new(meme_mapper_params)
    MemeMappers::Save.(meme_mapper: meme_mapper, fetch_data: true)
    redirect_to project_meme_mapper_path(project, @meme_mapper)
  end

  def show
    params[:page] ||= 1
    respond_to(&:js)
  end

  def edit
  end

  def update
    meme_mapper.update_attributes(meme_mapper_params)
    MemeMappers::Save.(meme_mapper: meme_mapper, fetch_data: false)
    redirect_to project_meme_mappers_path(project)
  rescue ActiveRecord::RecordInvalid
    render :edit
    respond_to(&:js)
  end

  def destroy
    meme_mapper.destroy!
    respond_to(&:js)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def meme_mapper
    @meme_mapper ||= MemeMapper.find(params[:id])
  end

  def meme_mapper_params
    params.require(:meme_mapper).permit(:name, :image_url).merge(project: project)
  end

  def presenter
    @presenter ||= MemeMapperPresenter.new(meme_mapper)
  end
end
