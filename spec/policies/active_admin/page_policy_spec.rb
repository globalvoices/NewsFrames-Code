require 'rails_helper'

describe ActiveAdmin::PagePolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  subject { described_class }

  permissions :show? do
    it 'only allows admin to access Dashboard' do
      record = instance_double("active_admin_record", :name => 'Dashboard')
      expect(subject).to_not permit(nil, record)
      expect(subject).to_not permit(user, record)
      expect(subject).to permit(admin, record)
    end

    it 'does not allow anyone to access unidentified resources' do
      record = instance_double("active_admin_record", :name => 'blah')
      expect(subject).to_not permit(nil, record)
      expect(subject).to_not permit(user, record)
      expect(subject).to_not permit(admin, record)
    end
  end
end