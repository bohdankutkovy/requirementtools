require 'spec_helper'

describe AssignmentsController, type: :controller do

  describe 'include helpers and filters' do
    it 'includes AssignmentsHelper module' do
      expect(subject.class).to receive(:include).with(AssignmentsHelper)
      load File.join(Rails.root, 'app/controllers/assignments_controller.rb')
    end

    it 'includes sign_in && entry_accessed filters' do
      expect(AssignmentsController).to receive(:before_filter).with(:ensure_user_is_signed_in?)
      expect(AssignmentsController).to receive(:before_filter).with(:entry_accessed?)
      load File.join(Rails.root, 'app/controllers/assignments_controller.rb')
    end
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
      it 'assigns @project and @assignments with assignments of this project' do
        p = FactoryGirl.create(:project)
        assignment = FactoryGirl.create(:assignment, project_id: p.id)
        get :show, id: p.id
        expect(assigns(:project)).to eq(p)
        expect(assigns(:assignments)).to include(assignment)
      end
    end

    describe 'GET new' do
      it 'assign @assignment with new Assignment' do
        p = FactoryGirl.create(:project)
        FactoryGirl.create(:assignment, project_id: p.id, user_id: user.id) #current project assignment with user
        get :new, assignment: {project_id: p.id}
        expect(assigns(:assignment)).to be_a_new(Assignment)
      end
    end

    describe 'POST create' do
      context 'valid params' do
        it 'assigns @assignment with created assignment' do
          p = FactoryGirl.create(:project)

          expect{post :create, assignment: {project_id: p.id, user_id: user.id, acl_level: 3}
          }.to change(Assignment, :count).by(1)
          expect(assigns(:assignment)).not_to be_nil
        end

        it 'renders assignment_path json' do
          p = FactoryGirl.create(:project)
          post :create, assignment: {project_id: p.id, user_id: user.id, acl_level: 3}
          expect(response.body).to eq("{\"page\":\"/assignments/#{Assignment.last.id}\"}")
        end
      end
      context 'invalid params' do
        it 'renders new_assignment_path' do
          post :create, assignment: {project_id: nil, user_id: user.id, acl_level: 3}
          expect(response.body).to eq("{\"page\":\"/assignments/new\"}")
        end
      end
    end

    describe 'GET edit' do
      let(:assignment){FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id)}
      let(:project){FactoryGirl.create(:project)}

      it 'finds assignment and assign it to @assignment' do
        get :edit, assignment: assignment.id, id: project.id
        expect(assigns(:assignment)).to eq(assignment)
      end
    end

    describe 'PUT update' do
      let(:assignment){FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id)}
      let(:project){FactoryGirl.create(:project)}

      it 'finds assignment and assign it to @assignment' do
        put :update, id: assignment.id, assignment: assignment.attributes
        expect(assigns(:assignment)).to eq(assignment)
      end

      context 'valid params' do
        it 'changes @assignment attr && renders assignment_path json' do
          a1 = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 3)
          put :update, id: a1.id, assignment: {project_id: a1.project_id, user_id: a1.user_id, acl_level: 2}
          expect(assigns(:assignment).acl_level).to eq(2)
          expect(response.body).to eq("{\"page\":\"/assignments/#{a1.id}\"}")
        end
      end

      context 'invalid params' do
        it 'changes @assignment attr && renders assignment_path json' do
          put :update, id: assignment.id, assignment: {project_id: nil, user_id: nil}
          expect(response).to render_template(:edit)
        end
      end
    end

    describe 'POST clear' do
      let(:assignment){FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id)}
      let(:project){FactoryGirl.create(:project)}

      it 'assigns @assignment with found assignment' do
        post :clear, assignment_id: assignment.id
        expect(assigns(:assignment)).to eq(assignment)
      end

      it 'destroys @assignment' do
        user2 = FactoryGirl.create(:user)
        assign1 = FactoryGirl.create(:assignment, project_id: project.id, user_id: user2.id, acl_level: 3)
        FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 1)
        expect{ post :clear, assignment_id: assign1.id
        }.to change(Assignment, :count).by(-1)
      end
    end

  end
end
