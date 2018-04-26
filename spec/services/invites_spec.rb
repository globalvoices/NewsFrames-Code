require 'rails_helper'

describe Invites do
  describe described_class::Create do

    it 'raises error if required parameters are not provided' do
      expect { described_class.(email: nil) }.to raise_error ArgumentError
      expect { described_class.(name: nil, email: Faker::Internet.email) }.to_not raise_error
    end

    it 'creates a new user in the system' do
      email = Faker::Internet.email
      name = Faker::Name.name

      user = described_class.(email: email, name: name)

      expect(user.name).to eq name
      expect(user.email).to eq email
      expect(user.invitation_accepted_at).to_not be
      expect(user.approved).to eq false
    end

    it 'invokes User.invite!' do
      email = Faker::Internet.email
      name = Faker::Name.name

      expect(User).to receive(:invite!).with(email: email, name: name)

      described_class.(email: email, name: name)
    end

  end

  describe described_class::AddAdmin do
    before { allow(Users::Approve).to receive(:call) }

    context 'existing approved user' do
      let!(:user) { create(:user) }

      it 'marks user as admin' do
        expect(user.admin?).to eq false
        expect(Users::Approve).to receive(:call).with(user: user, skip_email: true)
        
        described_class.(email: user.email)
        
        user.reload
        expect(user.admin?).to eq true
      end

      it 'calls user approve service' do
        expect(Users::Approve).to receive(:call).with(user: user, skip_email: true)
        described_class.(email: user.email)
      end

      it 'sends user an email' do
        expect { described_class.(email: user.email) }.to change { ActionMailer::Base.deliveries.count }.by 1
        delivery = ActionMailer::Base.deliveries.last
        expect(delivery.to).to eq [user.email]
        expect(delivery.body).to include '/admin'
        expect(delivery.body).to_not include 'invit'
      end

      it 'raises error if required parameters are not provided' do
        expect { described_class.(email: nil) }.to raise_error ArgumentError
        expect { described_class.(name: nil, email: user.email) }.to_not raise_error
      end
    end

    context 'existing non-approved user' do
      let!(:user) { create(:user, approved: false) }

      it 'marks user as admin' do
        expect(user.admin?).to eq false

        described_class.(email: user.email)
        
        user.reload
        expect(user.admin?).to eq true
      end

      it 'calls user approve service' do
        expect(Users::Approve).to receive(:call).with(user: user, skip_email: true)
        described_class.(email: user.email)
      end
    end

    context 'non-existing user' do
      let(:email) { Faker::Internet.email }
      let(:name) { Faker::Name.name }

      it 'creates user' do
        expect { described_class.(email: email, name: name) }.to change { User.count }.by 1
      end

      it 'marks user as an admin' do
        user = described_class.(email: email, name: name)
        expect(user.admin?).to eq true
        expect(user.email).to eq email
        expect(user.name).to eq name
      end

       it 'calls invite service' do
        expect(Invites::Create).to receive(:call).with(email: email, name: name, skip_email: true) { build(:user, name: name, email: email) }
        described_class.(email: email, name: name)
      end

       it 'calls user approve service' do
        expect(Users::Approve).to receive(:call).with(user: kind_of(User), skip_email: true)
        described_class.(email: email, name: name)
      end

      it 'sends user email' do
        expect { described_class.(email: email, name: name) }.to change { ActionMailer::Base.deliveries.count }.by 1
        delivery = ActionMailer::Base.deliveries.last
        expect(delivery.to).to eq [email]
        expect(delivery.body).to include '/admin'
        expect(delivery.body).to include 'invit'
      end

      it 'raises error if required parameters are not provided' do
        expect { described_class.(email: nil, name: name) }.to raise_error ArgumentError
        expect { described_class.(name: nil, email: email) }.to raise_error ArgumentError
      end
    end
  end
end
