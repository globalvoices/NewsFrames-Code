require 'rails_helper'

describe UsersController do

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe '#create' do
    let(:params) { { user: attributes_for(:user) } }
    let!(:admin1) { create(:admin) }
    let!(:admin2) { create(:admin) }

    before do 
      params[:user][:password_confirm] = params[:user][:password]       
    end

    it 'creates user' do
      expect { post :create, params: params }.to change { User.count }.by 1
    end

    it 'sends emails, for welcome and approval' do
      expect { post :create, params: params }.to change { ActionMailer::Base.deliveries.count }.by 2
      
      welcome_delivery = ActionMailer::Base.deliveries[-2]
      approval_delivery = ActionMailer::Base.deliveries.last

      expect(welcome_delivery.to).to eq [User.last.email]
      expect(welcome_delivery.subject).to include 'Welcome'

      expect(approval_delivery.to).to include admin1.email
      expect(approval_delivery.to).to include admin2.email
      expect(approval_delivery.subject).to include 'approval'
    end
  end
end
