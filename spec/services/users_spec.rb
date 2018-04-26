require 'rails_helper'

describe Users do

  describe described_class::Approve do
    context 'unapproved user' do
      let!(:user) { create(:user, approved: false) }

      before { allow(Etherpad::CreateAuthor).to receive(:call) }

      it 'marks user as approved' do
        expect(user.approved?).to eq false
        described_class.(user: user)
        user.reload
        expect(user.approved?).to eq true
      end

      it 'sends user an email' do
        expect { described_class.(user: user) }.to change { ActionMailer::Base.deliveries.count }.by 1
        delivery = ActionMailer::Base.deliveries.last
        expect(delivery.to).to eq [user.email]
        expect(delivery.subject).to include 'approved'
        expect(delivery.body).to include 'approved'
      end

      it 'raises error if required parameters are not provided' do
        expect { described_class.(user: nil) }.to raise_error ArgumentError
      end

      context 'no author ID' do
        before { user.author_id = nil }

        it 'creates an Etherpad author' do
          expect(Etherpad::CreateAuthor).to receive(:call) { double(:author, id: 'author-id') }
          described_class.(user: user)
          expect(user.author_id).to eq 'author-id'
        end
      end
    end

    context 'already approved user' do
      let!(:user) { create(:user, approved: true) }

      it 'does nothing' do
        expect(user.approved?).to eq true
        described_class.(user: user)
        user.reload
        expect(user.approved?).to eq true

        expect { described_class.(user: user) }.to_not change { ActionMailer::Base.deliveries.count }
      end
    end
  end
  describe described_class::Enable do
    context 'missing user' do
      it 'raises error if required parameters are not provided' do
        expect { described_class.(user: nil) }.to raise_error ArgumentError
      end
    end

    context 'enabled user' do
      let!(:user) { create(:user, enabled: true) }

      it 'does nothing' do
        expect(user.enabled?).to eq true
        described_class.(user: user)
        user.reload
        expect(user.enabled?).to eq true
      end
    end

    context 'disabled user' do
      let!(:user) { create(:user, enabled: false) }

      it 'marks the user as enabled' do
        expect(user.enabled?).to eq false
        described_class.(user: user)
        user.reload
        expect(user.enabled?).to eq true
      end
    end
  end

  describe described_class::Disable do
    context 'missing user' do
      it 'raises error if required parameters are not provided' do
        expect { described_class.(user: nil) }.to raise_error ArgumentError
      end
    end

    context 'disabled user' do
      let!(:user) { create(:user, enabled: false) }

      it 'does nothing' do
        expect(user.enabled?).to eq false
        described_class.(user: user)
        user.reload
        expect(user.enabled?).to eq false
      end
    end

    context 'enabled user' do
      let!(:user) { create(:user, enabled: true) }

      it 'marks the user as enabled' do
        expect(user.enabled?).to eq true
        described_class.(user: user)
        user.reload
        expect(user.enabled?).to eq false
      end
    end
  end
end
