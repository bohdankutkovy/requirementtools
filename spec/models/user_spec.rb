require 'spec_helper'


describe User do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  let(:user){FactoryGirl.create(:user)}

  before :each do
    User.destroy_all
  end

  describe 'ActiveModel validations' do


    it { expect(FactoryGirl.create(:user)).to validate_presence_of(:name) }
    it { expect(FactoryGirl.create(:user)).to validate_presence_of(:email) }
    it { expect(FactoryGirl.create(:user)).to validate_uniqueness_of(:name) }
    it 'has unique email' do
      expect(FactoryGirl.build(:user, email: user.email)).not_to be_valid
    end
    it 'validates password length' do
      expect(FactoryGirl.build(:user, password: "123" , password_confirmation: "123")).not_to be_valid
      expect(FactoryGirl.build(:user, password: "1234", password_confirmation: "1234")).to be_valid
      expect(FactoryGirl.build(:user, password: "1234567890123456", password_confirmation: "1234567890123456")).to be_valid
      expect(FactoryGirl.build(:user, password: "12345678901234567", password_confirmation: "12345678901234567")).not_to be_valid
    end

    it 'validates password confirmation' do
      expect(FactoryGirl.build(:user, password: "1234", password_confirmation: "4321")).not_to be_valid
    end
  end

  describe 'Model methods' do
    it 'disables the User' do
      user.disable_account
      expect(user.is_active).to eq(false)
    end

    it 'activates the User' do
      user_1 = FactoryGirl.create(:user, is_active: false)
      user_1.activate_account
      expect(user.is_active).to eq(true)
    end

    it 'returns status of user'  do
      expect(user.status).to eq(true)
    end

    it 'checks the password is changed' do
      user_1 = FactoryGirl.create(:user, sign_in_count: 1)
      user_1.update_attributes(info_edited: false)
      user_1.update_attributes(password: '1234', password_confirmation: '1234')
      user_1.send(:check_password_changed)
      expect(user_1.info_edited).to eq(true)
    end

    it 'checks if password is blank' do
      user.update_attributes(encrypted_password: '')
      expect(user.has_no_password?).to eq(true)
    end

    it 'confirms user authentication' do
      expect(user.active_for_authentication?).to eq(true)
    end

    it 'rejects user authentication' do
      user.update_attributes(is_active: false)
      expect(user.active_for_authentication?).to eq(false)
    end

    it 'sets the password' do
      user.attempt_set_password({password: '1234', password_confirmation: '1234'})
      expect(user.password).to eq('1234')
    end

    it 'checks if authorized for delete' do
      expect(user.authorized_for?({crud_type: 'create'})).to eq(true)
    end

  end


end