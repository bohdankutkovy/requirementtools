require 'spec_helper'

describe RequirementsController, type: :controller do

  describe 'controller filters and includes' do
    it 'includes UrlHelper && RequirementsHelper module' do
      expect(subject.class).to receive(:include).with(RequirementsHelper)
      expect(subject.class).to receive(:include).with(ActionView::Helpers::UrlHelper)
      load File.join(Rails.root, 'app/controllers/requirements_controller.rb')
    end

    it 'includes sign_in && entry_accessed filters' do
      expect(RequirementsController).to receive(:before_filter).with(:ensure_user_is_signed_in?)
      expect(RequirementsController).to receive(:before_filter).with(:entry_accessed?)
      load File.join(Rails.root, 'app/controllers/requirements_controller.rb')
    end
  end

  describe 'requirement controller actions' do

    user = FactoryGirl.create(:user)
    user.confirm!
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET index'do

      it 'get index page' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'assigns @requirements with proper requirements' do
        r1 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1)
        r2 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1, parent_id: r1.id)
        get :index, :project_id => 1
        expect(assigns(:requirements)).to eq([r1])
      end

    end

    describe 'GET show'do

      it 'get show page' do
        FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1)
        get :show, :id => 1
        expect(response.status).to eq(200)
      end

      it 'assigns @requirement with passed requirement id' do
        r1 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1)
        get :show, :id => r1.id
        expect(assigns(:requirement)).to eq(r1)
      end

    end

  end

end