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

  describe 'controller actions' do

    user = FactoryGirl.create(:user)
    user.confirm!
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET index'do

      it 'get index page with no requirements' do
        get :index, :project_id => 1
        expect(assigns(:requirements)).to eq([])
        expect(response.status).to eq(200)
      end

      it 'get index page with not valid project_id param' do
        get :index, :project_id => 'abc'
        expect(assigns(:requirements)).to eq([])
        expect(response.status).to eq(200)
      end

      it 'assigns @requirements with :parent_id => 0 and param[:project_id] requirements' do
        r1 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1)
        r2 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1, parent_id: r1.id)
        r3 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 4)
        r4 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1)
        get :index, :project_id => 1
        expect(assigns(:requirements)).to eq([r1, r4])
        expect(response.status).to eq(200)
      end

      it 'assigns @requirements with only active requirements' do
        r1 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1)
        r2 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1, is_active: false)
        r4 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1, is_active: true, parent_id: r2.id) #if parent is non-active it will not be added to json
        r3 = FactoryGirl.create(:requirement, author_id: user.id, :project_id=> 1, parent_id: r1.id)
        get :index, :project_id => 1
        expect(response.body).to eq("{\"requirements\":[{\"text\":\"<a class=\\\"treerequirement frame-link\\\" id=\\\"#{r1.id}\\\" href=\\\"/requirements/#{r1.id}\\\">some title</a>\",\"nodes\":[{\"text\":\"<a class=\\\"treerequirement frame-link\\\" id=\\\"#{r3.id}\\\" href=\\\"/requirements/#{r3.id}\\\">some title</a>\",\"nodes\":[]}]}]}")
        expect(response.status).to eq(200)
      end

    end

    describe 'GET show'do

      it 'assigns the requested requirement to @requirement' do
        r1 = FactoryGirl.create(:requirement, author_id: user.id)
        get :show, :id => r1
        expect(assigns(:requirement)).to eq(r1)
        expect(response.status).to eq(200)
      end

      it 'renders the #show view' do
        get :show, id: FactoryGirl.create(:requirement)
        expect(response).to render_template :show
      end

      it 'assigns the associated requirement attachment to @requirement_attachments' do
        r1 = FactoryGirl.create(:requirement, author_id: user.id)
        r1.attachments << FactoryGirl.create(:attachment)
        get :show, :id => r1
        expect(assigns(:requirement_attachments)).to eq(r1.attachments)
        expect(response.status).to eq(200)
      end

    end

  end

end