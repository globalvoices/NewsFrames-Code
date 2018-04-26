ActiveAdmin.register Project do
  actions :index, :show, :edit, :update, :destroy
  permit_params :name, :lead

  index do
    column :name { |project| link_to(project.name, admin_project_path(project)) }
    column :lead { |project| project.lead }
    column :link { |project| link_to(project_path(project), project_path(project)) }
    column :created_at
    column :updated_at
  end

  show do
    attributes_table do
      row :id
      row :name
      row :lead { |project| project.lead }
      row :pad_id
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    inputs 'Project' do
      input :name
      input :lead, as: :select, collection: resource.users, required: true, selected: resource.lead.try(:id), include_blank: false
    end

    actions
  end

  controller do
    def update
      ActiveRecord::Base.transaction do
        super

        lead_user = User.find(permitted_params[:project][:lead])
        lead_collaborator = resource.collaborators.find_by!(user: lead_user)
        Collaborators::Promote.(collaborator: lead_collaborator)
      end
    end

    def destroy
      Projects::Delete.(project: resource)
      redirect_to admin_projects_path
    end

    private

    def resource_params
      super.tap do |result|
        result.first.delete(:lead)
      end
    end
  end

  filter :created_at
  filter :updated_at

  config.sort_order = 'created_at_desc'
end
