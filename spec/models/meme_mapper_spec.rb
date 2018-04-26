require 'rails_helper'

describe MemeMapper do
  it 'has valid factory' do
    expect(create(:meme_mapper)).to be_valid
  end

  describe 'validations' do
    it 'validates presence of image URL' do
      expect(build(:meme_mapper, image_url: nil)).to_not be_valid
    end
  end
end
