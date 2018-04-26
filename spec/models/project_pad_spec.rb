require 'rails_helper'

describe ProjectPad do
  it 'has a valid factory' do
    expect(create(:project_pad, index: 1)).to be_valid
  end

  describe 'validations' do
    it 'validates presence of name' do
      expect(build(:project_pad, name: nil)).to_not be_valid
    end
  end
end
