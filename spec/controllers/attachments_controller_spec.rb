require 'spec_helper'

describe AttachmentsController, type: :controller do
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

    describe 'POST create' do
      it 'passes attachment params to action' do
        r = FactoryGirl.create(:requirement)
        post :create, attachment: {requirement_id: r.id, file: [fixture_file_upload('spec/fixtures/file/pdf.pdf', 'pdf/pdf')]}
        expect(controller.params[:attachment]).not_to be_nil
      end

      it 'creates new attachment and renders the edit_requirement path json' do
        r = FactoryGirl.create(:requirement, author_id: user.id)
        expect{
          post :create, attachment: {requirement_id: r.id, file: [fixture_file_upload('spec/fixtures/file/pdf.pdf', 'pdf/pdf')]}
        }.to change(Attachment,:count).by(1)

        expect(response.body).to eq("{\"page\":\"/requirements/#{r.id}/edit?requirement=#{r.id}\"}")
      end

    end

    describe 'POST clear' do
      it 'finds the attachment and assigns it to @attachment' do
        attachment = FactoryGirl.create(:attachment)
        post :clear, attachment_id: attachment.id
        expect(assigns(:attachment)).to eq(attachment)
      end

      it 'destroys the @attachment and renders the edit_requirement path json' do
        r = FactoryGirl.create(:requirement)
        attachment = FactoryGirl.create(:attachment, requirement_id: r.id)
        post :clear, attachment_id: attachment.id
        expect(response.body).to eq("{\"page\":\"/requirements/#{r.id}/edit?requirement=#{r.id}\"}")
      end

    end

  end
end
