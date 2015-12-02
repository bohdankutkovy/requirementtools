require 'spec_helper'


describe ProfilesController, type: :controller do
  it 'includes set_user filters' do
    expect(ProfilesController).to receive(:before_filter).with(:set_user, {:only=>[:show, :edit, :update]})
    load File.join(Rails.root, 'app/controllers/profiles_controller.rb')
  end

  context 'controller actions' do
    let(:user){FactoryGirl.create(:user)}

    before :each do
      User.destroy_all
      Project.destroy_all
      Attachment.destroy_all
      Requirement.destroy_all

      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end


    describe 'GET show' do
      it 'assigns @user with found user' do
        get :show, id: user.id
        expect(assigns(:user)).to eq(user)
      end
    end

    describe 'GET edit' do
      it 'triggers @Edit your password@ message if user didnt edit password' do
        user.update_attributes(info_edited: false)
        get :edit, id: user.id
        expect(flash[:notice]).to eq('Edit your password!')
      end
    end

    describe 'PUT update' do
      let(:user_1){FactoryGirl.create(:user)}
      let(:admin){FactoryGirl.create(:user, is_super_admin: true)}
      context 'with valid params' do
        it 'updates attributes of @user flashes notice and redirects to edit path' do
          put :update, id: user.id, user: {name: 'Updated', email: user.email, password: '', password_confirmation: '', avatar_cache: ''}
          assigns(:user).reload
          expect(assigns(:user).name).to eq('Updated')
          expect(flash[:notice]).to eq('Profile updated!')
          expect(redirect_to(profile_path(assigns(:user))))
        end

        it 'updates attributes of @user flashes notice and redirects to edit path' do
          put :update, id: user.id, user: {name: 'Updated', email: user.email, password: '', password_confirmation: '', avatar_cache: ''}
          assigns(:user).reload
          expect(assigns(:user).name).to eq('Updated')
          expect(flash[:notice]).to eq('Profile updated!')
          expect(redirect_to(profile_path(assigns(:user))))
        end

        it 'updates attributes of admin user flashes notice and redirects to edit path' do
          sign_out user
          sign_in admin

          put :update, id: admin.id, user: {name: 'Updated', email: admin.email, password: '', password_confirmation: '', avatar_cache: ''}
          assigns(:user).reload
          expect(assigns(:user).name).to eq('Updated')
          expect(flash[:notice]).to eq('Profile updated!')
          expect(redirect_to(profile_path(assigns(:user))))
        end

        it 'updates attributes of user by admin flashes notice and redirects to user_profile path' do
          sign_out user
          sign_in admin
          put :update, id: user.id, user: {name: 'Updated', email: user.email, password: '', password_confirmation: '', avatar_cache: ''}
          assigns(:user).reload
          expect(assigns(:user).name).to eq('Updated')
          expect(flash[:notice]).to eq('Profile updated!')
          expect(redirect_to(profile_path(assigns(:user))))
        end

      end

      context 'with invalid params' do
        it 'updates attributes of @user flashes notice and redirects to edit path' do
          put :update, id: user.id, user: {name: user_1.name, email: user_1.email, password: '', password_confirmation: '', avatar_cache: ''}
          assigns(:user).reload
          expect(assigns(:user).name).to eq(user.name)
          expect(flash[:error]).to eq('Profile was not updated! Some attribute is invalid!')
          expect(response).to render_template(:edit)
        end
      end

    end
  end


end

