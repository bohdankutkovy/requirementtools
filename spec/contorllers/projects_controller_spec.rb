require 'spec_helper'

describe ProjectsController, type: :controller do
  describe 'controller filters and includes' do
    it 'includes sign_in && entry_accessed filters' do
      expect(RequirementsController).to receive(:before_filter).with(:ensure_user_is_signed_in?)
      expect(RequirementsController).to receive(:before_filter).with(:entry_accessed?)
      load File.join(Rails.root, 'app/controllers/requirements_controller.rb')
    end
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


    describe 'GET show' do
      let(:project){FactoryGirl.create(:project)}
      context 'valid param'
        it 'passes project id param to show template and assigns @project with found project' do
          get :show, id: project.id

          expect(controller.params[:id]).to eq(project.id.to_s)
          expect(assigns(:project)).to eq(project)
        end
      end
      context 'invalid param' do
        it 'renders nothing if param is not valid' do
          get :show, id: '-'

          expect(response.body).to eq("")
          expect(response.status).to eq(200)
        end
      end
    end

  end
end