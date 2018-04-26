require 'rails_helper'

describe ApplicationForm do

  it 'validates the presence of mandatory items' do
    expect(build(:application_form, user: nil)).to_not be_valid
  end

  it 'throws error when saved' do
    expect { create(:application_form) }.to raise_error RuntimeError
  end
  
end