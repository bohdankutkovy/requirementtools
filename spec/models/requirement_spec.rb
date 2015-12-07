require 'spec_helper'

describe Requirement do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:requirement)).to be_valid
  end


end