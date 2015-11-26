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

    describe 'GET show' do

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

    describe 'GET new' do

      let(:project){ FactoryGirl.create(:project) }

      it 'passes project_id params to new action' do
        params = {:project_id => project.id}
        get :new, :requirement => params
        expect(controller.params[:requirement]).to eq({"project_id" => project.id.to_s})
      end

      it 'assigns the requirement build to @requirement' do
        params = {:project_id => project.id}
        get :new, :requirement => params
        expect(assigns(:requirement).project_id).to eq(project.id)
      end

      it 'assigns the attachment build to @requirement_attachments' do
        params = {project_id: project.id}
        get :new, :requirement => params
        expect(assigns(:requirement_attachment)).not_to be_nil
        expect(assigns(:requirement_attachment)).not_to eq([])
      end
    end

    describe 'POST create' do

      context 'creates with valid attributes' do
        it 'creates a new requirement' do
          expect{
            post :create, requirement: FactoryGirl.attributes_for(:requirement)
          }.to change(Requirement,:count).by(1)
        end

        it 'renders requirement show path (json)' do
          post :create, requirement: { project_id: 1, parent_id: 0, title: "some title", description: "some description", priority: 5, worth: 10, created_at: "2015-11-26 15:17:55", updated_at: "2015-11-26 15:17:55", author_id: nil, is_active: true}
          expect(response.body).to eq("{\"page\":\"/requirements/#{Requirement.last.id}\"}")
        end

        it 'creates a new attachment for requirement' do
          post :create, requirement: { project_id: 1, parent_id: 0, title: "some title", description: "some description", priority: 5, worth: 10, created_at: "2015-11-26 15:17:55", updated_at: "2015-11-26 15:17:55", author_id: nil, is_active: true}, attachments: {file: [fixture_file_upload('spec/fixtures/file/pdf.pdf', 'pdf/pdf')]}
          expect(assigns(:requirement).attachments).not_to eq([])
        end
      end

      context 'with invalid attributes' do
        it 'does not save requirement' do
          expect{
            post :create, requirement: FactoryGirl.attributes_for(:requirement, title: '' )
          }.not_to change(Requirement,:count)
        end

        it 'renders new requirement path (json)' do
          post :create, requirement: FactoryGirl.attributes_for(:requirement, title: '' )
          expect(response.body).to eq("{\"page\":\"/requirements/new\"}")
        end
      end

    end

  end

end