require 'csv'

ActiveAdmin.register Checklist do

  actions :index, :show, :destroy

  action_item only: :index do
    link_to 'Upload checklist', action: 'upload_checklist'
  end

  action_item only: :show do
    # don't show edit if translations exist
    link_to 'Edit checklist', action: 'edit_checklist'
  end

  action_item only: :show do
    link_to 'Add translation', action: 'add_translation'
  end

  index do
    column :id

    column :name do |list|
      list.with_translation_in_current_locale.name
    end

    column :items do |list|
      list.items.length
    end

    column :enabled do |list|
      if list.enabled?
        link_to 'Disable', disable_admin_checklist_path(list),
                method: :post, data: { confirm: 'Are you sure you want to disable the checklist?' }
      else
        link_to 'Enable', enable_admin_checklist_path(list),
                method: :post, data: { confirm: 'Are you sure you want to enable the checklist?' }
      end
    end

    actions
  end

  show do
    Globalize.with_locale :en_US do
      render 'show', checklist: resource
    end
  end

  form do |f|
    render 'overwrite', checklist: resource
  end

  config.sort_order = 'created_at_desc'

  filter :created_at
  filter :updated_at
  filter :enabled

  collection_action :upload_checklist, :method => :get do
    authorize(Checklist)
    render 'upload_checklist'
  end

  collection_action :import, :method => :post do
    authorize(Checklist)
    unless params[:name].present?
      flash[:error] = 'Checklist name not provided'
      return redirect_to upload_checklist_admin_checklists_path
    end

    unless params[:file].present?
      flash[:error] = 'Checklist file not provided'
      return redirect_to upload_checklist_admin_checklists_path
    end

    begin
      items = parse_checklist_csv(params)
      Checklists::Create.(name: params[:name], items: items)
      redirect_to :action => :index, :notice => "Checklist imported successfully."
    rescue
      flash[:error] = 'Checklist could not be imported. Please check the format.'
      redirect_to upload_checklist_admin_checklists_path
    end
  end

  member_action :edit_checklist, :method => :get do
    authorize(resource)
    Globalize.with_locale :en_US do
      @checklist = Checklist.find(params[:id])
      render 'overwrite'
    end
  end

  member_action :overwrite, :method => :post do
    authorize(resource)
    unless params[:name].present?
      flash[:error] = 'Checklist name not provided'
      return redirect_to edit_checklist_admin_checklist_path(id: resource.id)
    end

    begin
      Checklists::Update.(checklist: resource, name: params[:name])
      redirect_to admin_checklist_path(id: resource.id), notice: 'Checklist updated successfully'
    rescue
      flash[:error] = 'Checklist could not be updated.'
      redirect_to edit_checklist_admin_checklist_path(id: resource.id)
    end
  end

  member_action :add_translation, :method => :get do
    authorize(resource)
    Globalize.with_locale :en_US do
      @checklist = Checklist.find(params[:id])
      render 'upload_translation'
    end
  end

  member_action :upload_translation, :method => :post do
    authorize(resource)
    unless params[:name].present?
      flash[:error] = 'Checklist name not provided'
      return redirect_to add_translation_admin_checklist_path(id: resource.id)
    end

    unless params[:language].present?
      flash[:language] = 'Locale not selected'
      return redirect_to add_translation_admin_checklist_path(id: resource.id)
    end

    begin
      items = parse_checklist_csv(params) if params[:file].present?
      Checklists::AddTranslation.(checklist: resource, language: params[:language], name: params[:name], items: items)
      redirect_to admin_checklist_path(id: resource.id), notice: 'Translation added successfully'
    rescue ServiceError => e
      flash[:error] = e.message || 'Checklist could not be imported. Please check the format.'
      redirect_to add_translation_admin_checklist_path(id: resource.id)
    rescue StandardError
      flash[:error] = 'Checklist could not be imported. Please check the format.'
      redirect_to add_translation_admin_checklist_path(id: resource.id)
    end
  end

  member_action :edit_translation, :method => :get do
    authorize(resource)
    @language = params[:language]
    @original_checklist = Checklist.find(params[:id])

    @checklist_items = @original_checklist.items.map { |entry| entry.with_translation(params[:language].to_sym) }
    @checklist = @original_checklist.with_translation(params[:language].to_sym)

    render 'overwrite_translation'
  end

  member_action :show_translation, :method => :get do
    authorize(resource)
    @original_checklist = Checklist.find(params[:id])
    @language = params[:language]

    @checklist_items = @original_checklist.items.map { |entry|  entry.with_translation(params[:language].to_sym) }
    @checklist = @original_checklist.with_translation(params[:language].to_sym)

    render '_show_translation'
  end

  member_action :overwrite_translation, :method => :post do
    authorize(resource)

    language = params[:language]

    unless params[:name].present?
      flash[:error] = 'Checklist name not provided'
      return redirect_to edit_translation_admin_checklist_path(id: resource.id, language: language)
    end

    begin
      Checklists::UpdateTranslation.(checklist: resource, name: params[:name], language: language)
      redirect_to show_translation_admin_checklist_path(id: resource.id, language: language), notice: 'Checklist translation updated successfully'
    rescue
      flash[:error] = 'Checklist translation could not be updated.'
      redirect_to edit_translation_admin_checklist_path(id: resource.id, language: language)
    end
  end

  member_action :remove_translation, :method => :delete do
    authorize(resource)

    Checklists::RemoveTranslation.(checklist: resource, language: params[:language].to_sym)
    redirect_to admin_checklist_path(id: resource.id), notice: 'Translation removed successfully'
  end

  member_action :enable, method: :post do
    authorize(resource)
    Checklists::Enable.call(checklist: resource)
    redirect_to admin_checklists_path
  end

  member_action :disable, method: :post do
    authorize(resource)
    Checklists::Disable.call(checklist: resource)
    redirect_to admin_checklists_path
  end

  controller do

    def parse_checklist_csv(params)
      csv_data = params[:file]
      csv_file = csv_data.read
      items = []
      CSV.parse(csv_file) do |row|
        items.push(item: row[0], help: row[1])
      end
      items
    end
  end
end
