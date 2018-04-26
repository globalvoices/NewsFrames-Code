ActiveAdmin.register User do
  permit_params :name, :email, :password, :password_confirmation, :approved, role_ids: []

  controller do
    include ApplicationHelper
    def update
      if params[:user][:password].blank?
        params[:user].delete "password"
        params[:user].delete "password_confirmation"
      end

      super
    end

    def create
      user_params = params[:user]
      ActiveRecord::Base.transaction do
        user = Invites::Create.(email: user_params[:email], name: user_params[:name])
        Users::Approve.(user: user, skip_email: true)
        user_params[:role_ids].each do |role_id|
          user.add_role(Role.find(role_id).name) if role_id.present?
        end
      end
      redirect_to admin_users_path
    end

  end

  form do |f|
    inputs 'User' do
      input :name
      input :email
      
      if f.object.id.present?
        input :password
        input :password_confirmation
      end

      input :roles, as: :check_boxes, collection: Role.all
    end
    actions
  end

  index do
    column :id

    column :name
    column :email
    
    column :approved do |user|
      if user.approved?
        "\u2713"
      else
        link_to 'Approve', approve_admin_user_path(user), 
                method: :post, data: { confirm: 'Are you sure you want to approve the user?' }
      end
    end

    column :enabled do |user|
      if user.enabled?
        if user.id != current_user.id && !user.admin?
          link_to 'Disable', disable_admin_user_path(user), 
                  method: :post, data: { confirm: 'Are you sure you want to disable the user?' }
        else
          "\u2714"
        end
      else
        link_to 'Enable', enable_admin_user_path(user), 
                method: :post, data: { confirm: 'Are you sure you want to enable the user?' }
      end
    end

    column :roles do |user|
      user.roles.collect {|r| r.name.capitalize }.to_sentence
    end

    actions
  end

  config.sort_order = 'created_at_desc'
  
  filter :name
  filter :email
  filter :approved, as: :select, collection: [["Yes", true], ["No", false]]
  filter :enabled, as: :select, collection: [["Yes", true], ["No", false]]
  filter :with_role, as: :select, label: 'Role', collection: Role.roles

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :roles do |user|
        user.roles.collect {|r| r.name.capitalize }.to_sentence
      end
      row :approved do |user|
        if user.approved?
          "\u2714"
        else
          "\u2718"
        end
      end
      row :enabled do |user|
        if user.enabled?
          "\u2714"
        else
          "\u2718"
        end
      end
      row :created_at
      row :updated_at
    end
  end

  member_action :approve, method: :post do
    authorize(resource)
    Users::Approve.call(user: resource)
    redirect_to admin_users_path
  end

  member_action :enable, method: :post do
    authorize(resource)
    Users::Enable.call(user: resource)
    redirect_to admin_users_path
  end

  member_action :disable, method: :post do
    authorize(resource)
    Users::Disable.call(user: resource)
    redirect_to admin_users_path
  end
end