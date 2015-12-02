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

    describe 'GET edit' do
      let(:requirement){ FactoryGirl.create(:requirement) }

      it 'passes requrement & id params to edit action' do
        get :edit, {requirement: requirement.id, id: requirement.id}
        expect(controller.params[:requirement]).to eq(requirement.id.to_s)
        expect(controller.params[:id]).to eq(requirement.id.to_s)
      end

      it 'finds existing requirement and assigns it to @requirement' do

        get :edit, {requirement: requirement.id, id: requirement.id}
        expect(assigns(:requirement)).to eq(requirement)
      end

      it 'finds all attachments of @requirement and assigns them to @attachments' do

        get :edit, {requirement: requirement.id, id: requirement.id}
        expect(assigns(:attachments)).to eq(assigns(:requirement).attachments.all)
      end

      it 'initalize @requirement_attachment in case of new attachment' do
        get :edit, {requirement: requirement.id, id: requirement.id}
        expect(assigns(:requirement_attachment)).not_to be_nil
        expect(assigns(:requirement_attachment)).not_to eq([])
      end
    end

    describe 'PUT update' do
      let(:requirement){FactoryGirl.create(:requirement)}

      it 'passes id & requirement params to update action' do
        put :update, {id: requirement.id, requirement: requirement.attributes}
        expect(controller.params[:id]).to eq(requirement.id.to_s)
        expect(controller.params[:requirement]).not_to be_nil
      end

      it 'finds the requirement and assigns it to @requirement' do
        put :update, {id: requirement.id, requirement: requirement.attributes}
        expect(assigns(:requirement)).to eq(requirement)
      end


      context 'updates with invalid attributes' do

        it 'does not update a requirement and redirects to edit_requirement path' do
          put :update, {id: requirement.id, requirement: FactoryGirl.attributes_for(:requirement, title: '',
                                                                                                  description: "invalid update")}
          assigns(:requirement).reload
          expect(assigns(:requirement).description).not_to eq('invalid update')
          expect(response).to render_template :edit
        end
      end

      context 'updates with valid attributes' do
        it 'updates with valid attributes and renders requirement_path json' do
          put :update, {id: requirement.id, requirement: requirement.attributes}
          expect(response.body).to eq("{\"page\":\"/requirements/#{requirement.id}\"}")
        end
      end
    end

    describe 'POST clear' do
      it 'renders fathers show template' do
        project = FactoryGirl.create(:project)
        requirement_father = FactoryGirl.create(:requirement, project_id: project.id)
        requirement_child = FactoryGirl.create(:requirement, project_id: project.id, parent_id: requirement_father.id)

        post :clear, requirement_id: requirement_child.id
        expect(response.body).to eq("{\"page\":\"/requirements/#{requirement_father.id}\"}")
      end

      it 'renders projects show template' do
        project = FactoryGirl.create(:project)
        requirement_father = FactoryGirl.create(:requirement, project_id: project.id)

        post :clear, requirement_id: requirement_father.id
        expect(response.body).to eq("{\"page\":\"/projects/#{project.id}\"}")
      end
    end

    describe 'POST version_rollback' do
      let(:requirement){FactoryGirl.create(:requirement)}
      it 'passes requirement_id and version_id and and assigns @requirement' do
        post :version_rollback, {version: 1, requirement_id: requirement.id}
        expect(assigns(:requirement)).to eq(requirement)
      end

      context 'with valid version param' do
        it 'passes requirement_id and version_id, rollbacks to the previous version and renders requirement_path json' do
          requirement.update_attributes(title: 'Updated')
          post :version_rollback, {version: 1, requirement_id: requirement.id}

          expect(controller.params[:requirement_id]).to eq(requirement.id.to_s)
          expect(controller.params[:version]).to eq(1.to_s)
          expect(assigns(:requirement).title).to eq("some title")
          expect(response.body).to eq("{\"page\":\"/requirements/#{requirement.id}\"}")
        end
      end

      context 'with invalid version param' do
        it 'doesnt rollback to previous version' do
          requirement.update_attributes(title: 'Updated')
          post :version_rollback, {version: '300', requirement_id: requirement.id}

          expect(assigns(:requirement).title).to eq("Updated")
          expect(response.body).to eq("{\"page\":\"/requirements/#{requirement.id}\"}")
        end
      end

    end

  end

end