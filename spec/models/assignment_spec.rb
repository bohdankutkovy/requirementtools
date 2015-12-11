require 'spec_helper'


describe Assignment do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:assignment)).to be_valid
  end

  let(:assignment){FactoryGirl.create(:assignment)}
  let(:project){FactoryGirl.create(:project)}
  let(:user){FactoryGirl.create(:user)}

  before :each do
    Project.destroy_all
    Assignment.destroy_all
    User.destroy_all
  end

  describe 'ActiveModel validations' do
    it { expect(assignment).to validate_presence_of(:acl_level) }
    it { expect(assignment).to validate_presence_of(:project_id) }
    # it { should validate_uniqueness_of(:user_id).scoped_to(:project_id) }

    it 'validates the numericality of acl_level' do
      assignment.update_attributes(acl_level: -1)
      expect(assignment).to be_invalid
      assignment.update_attributes(acl_level: 3)
      expect(assignment).to be_valid
      assignment.update_attributes(acl_level: 4)
      expect(assignment).to be_invalid
    end

    it 'validates uniqueness of user scope project and raises a message' do
      expect(FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id))
          .to be_valid
      invalid_assignment = FactoryGirl.build(:assignment, project_id: project.id, user_id: user.id)
      expect(invalid_assignment).not_to be_valid
      expect(invalid_assignment.errors[:user_id]).to include('cannot be assigned to one project more than once')
    end
  end

  describe 'model methods' do
    it 'return users name of current assignment' do
      expect(FactoryGirl.create(:assignment, user_id: user.id, project_id: project.id).name).to eq(user.name)
    end


    context 'assigned with rich rights' do
      it 'allows user to create assignment' do
        user_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 1)
        expect(user_assignment.available_for_create?(user)).to eq(true)
      end

      it 'allows user to read assignment' do
        user_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 3)
        expect(user_assignment.available_for_read?(user)).to eq(true)
      end

      it 'allows user to update assignment if current user acl > assignments acl' do
        user_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 0)
        some_user = FactoryGirl.create(:user)
        some_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: some_user.id, acl_level: 3)
        expect(some_assignment.available_for_update?(user)).to eq(true)

        #acl_level = 1 > assignment.acl = 3
        user_assignment.update_attributes(acl_level: 1)
        expect(some_assignment.available_for_update?(user)).to eq(true)

        #acl_level = 2 > assignment.acl = 3
        user_assignment.update_attributes(acl_level: 2)
        expect(some_assignment.available_for_update?(user)).to eq(true)
      end

      it 'allows user to update assignment if current user acl > assignments acl' do
        user_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 0)
        some_user = FactoryGirl.create(:user)
        some_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: some_user.id, acl_level: 3)
        expect(some_assignment.available_for_delete?(user)).to eq(true)

        #acl_level = 1 > assignment.acl = 3
        user_assignment.update_attributes(acl_level: 1)
        expect(some_assignment.available_for_delete?(user)).to eq(true)

        #acl_level = 2 > assignment.acl = 3
        user_assignment.update_attributes(acl_level: 2)
        expect(some_assignment.available_for_delete?(user)).to eq(true)
      end
    end

    context 'assigned with poor rights' do
      it 'doesnt allow user to create assignment' do
        user_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 3)
        expect(user_assignment.available_for_create?(user)).to eq(false)
      end

      it 'doesnt allow to update assignments if current_user.acl < assignments.acl' do
        user_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 3)
        some_user = FactoryGirl.create(:user)
        some_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: some_user.id, acl_level: 0)
        expect(some_assignment.available_for_update?(user)).to eq(false)

        #acl_level = 2 < assignment.acl = 1
        user_assignment.update_attributes(acl_level: 2)
        some_assignment.update_attributes(acl_level: 1)
        expect(some_assignment.available_for_update?(user)).to be_nil

        #acl_level = 1 < assignment.acl = 0
        user_assignment.update_attributes(acl_level: 1)
        some_assignment.update_attributes(acl_level: 0)
        expect(some_assignment.available_for_update?(user)).to be_nil
      end

      it 'doesnt allow to delete assignments if current_user.acl < assignments.acl' do
        user_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 3)
        some_user = FactoryGirl.create(:user)
        some_assignment = FactoryGirl.create(:assignment, project_id: project.id, user_id: some_user.id, acl_level: 0)
        expect(some_assignment.available_for_delete?(user)).to eq(false)

        #acl_level = 2 < assignment.acl = 1
        user_assignment.update_attributes(acl_level: 2)
        some_assignment.update_attributes(acl_level: 1)
        expect(some_assignment.available_for_delete?(user)).to eq(false)

        #acl_level = 1 < assignment.acl = 0
        user_assignment.update_attributes(acl_level: 1)
        some_assignment.update_attributes(acl_level: 0)
        expect(some_assignment.available_for_delete?(user)).to eq(false)
      end

    end




  end


end
