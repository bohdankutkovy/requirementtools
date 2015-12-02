require 'spec_helper'

describe DashboardsController, type: :controller do
  it 'includes entry_accessed filter' do
    expect(DashboardsController).to receive(:before_filter).with(:entry_accessed?, {only: :index})
    load File.join(Rails.root, 'app/controllers/dashboards_controller.rb')
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

    context 'index action' do

      it 'assigns @user with current user' do
        get :index
        expect(assigns(:user)).to eq(user)
      end

      it 'assigns @projects with all projects if current user is super_admin' do
        user.update_attributes(is_super_admin: true)
        FactoryGirl.create(:project)
        FactoryGirl.create(:project)
        get :index
        expect(assigns(:projects).count).to eq(2)
      end

      it 'assigns @projects only with assigned to user projects' do
        p1 = FactoryGirl.create(:project)
        p2 = FactoryGirl.create(:project)
        FactoryGirl.create(:assignment, project_id: p1.id, user_id: user.id)
        get :index
        expect(assigns(:projects)).to include(p1)
        expect(assigns(:projects)).not_to include(p2)
      end
    end
  end


end