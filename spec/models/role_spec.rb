require 'rails_helper'

describe Role do
  it 'has valid factory' do
    expect(create(:role)).to be_valid
  end

  describe 'validations' do
    it 'validates the presence of name' do
      expect(build(:role, name: nil)).to_not be_valid
    end

    it 'enforces name to be within predefined list' do
      expect(build(:role, name: 'admin')).to be_valid
      expect(build(:role, name: 'wrong')).to_not be_valid
    end
  end  
end