require 'spec_helper'


describe ProfilesController, type: :controller do
  it 'includes sign_in && entry_accessed filters' do
    expect(ProfilesController).to receive(:before_filter).with(:set_user, {:only=>[:show, :edit, :update]})
    load File.join(Rails.root, 'app/controllers/profiles_controller.rb')
  end

  context 'controller actions' do
    user = User.new
    user.name = Faker::Name.first_name
    user.email = Faker::Internet.email
    user.password = "password"
    user.password_confirmation = "password"
    user.info_edited = true
    user.is_super_admin = false
    user.is_active = true
    user.save

    user.confirm!

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    context 'get show' do
      it 'assigns @user with found user' do
        get :show, id: user.id
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'get edit' do
      it 'triggers @Edit your password@ message if user didnt edit password' do
        user.update_attributes(info_edited: false)
        get :edit, id: user.id
        expect(flash[:notice]).to eq('Edit your password!')
      end
    end
  end


end

