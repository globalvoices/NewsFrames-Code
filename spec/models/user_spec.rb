require 'rails_helper'

describe User do
  it 'has valid factory' do
    expect(create(:user)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of email' do
      expect(build(:user, email: nil)).to_not be_valid
    end

    it 'validates that email provided is valid' do
      expect(build(:user, email: 'cris+4@colab')).to_not be_valid
    end

    it 'validates the presence of password' do
      expect(build(:user, password: nil)).to_not be_valid
    end

    it 'validates the minimum password length' do
      expect(build(:user, password: 'testing')).to_not be_valid
    end

    it 'validates presence of language' do
      expect(build(:user, language: nil)).to_not be_valid
    end

    it 'validates max length of initials' do
      expect(build(:user, initials: 'abcdefghijk')).to_not be_valid
    end

    context 'name required' do
      it 'validates the presence of name' do
        expect(build(:user, name_required: true, name: nil)).to_not be_valid
      end
    end
  end

  it 'no default role assigned to user'  do
    user = create(:user)
    expect(user.roles.length).to eq 0
  end

  describe '#short_name' do
    let(:user) { create(:user) }

    context 'with initials' do
      before { user.initials = 'ABC' }

      it { expect(user.short_name).to eq 'ABC' }
    end

    context 'with name' do
      before { user.name = 'Foo Bar' }

      it { expect(user.short_name).to eq 'FB' }

      context 'with single word name' do
        before { user.name = 'Foo' }

        it { expect(user.short_name).to eq user.email }
      end
    end

    context 'no name' do
      before { user.name = nil }

      it { expect(user.short_name).to eq user.email }
    end
  end
end
