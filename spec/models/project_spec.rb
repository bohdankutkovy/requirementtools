require 'spec_helper'


describe Project do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:project)).to be_valid
  end

  let(:project){FactoryGirl.create(:project)}
  let(:user){FactoryGirl.create(:user)}

  before :each do
    Project.destroy_all
    Assignment.destroy_all
  end

  describe 'ActiveModel validations' do
    it { expect(project).to validate_presence_of(:title) }
    it { expect(project).to validate_presence_of(:description) }
    it { should validate_uniqueness_of(:title) }
  end

  describe 'Model methods' do
    it 'returns unassigned active users to project' do
      u1 = FactoryGirl.create(:user)
      u2 = FactoryGirl.create(:user)
      u3 = FactoryGirl.create(:user, is_active: false)
      u4 = FactoryGirl.create(:user)
      FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 3)
      FactoryGirl.create(:assignment, project_id: project.id, user_id: u1.id, acl_level: 3)
      FactoryGirl.create(:assignment, project_id: project.id, user_id: u2.id, acl_level: 3)
      FactoryGirl.create(:assignment, project_id: project.id, user_id: u3.id, acl_level: 3)

      expect(project.unassigned_users).to include(u4)
      expect(project.unassigned_users).not_to include(u1, u2, user, u3)
    end

    context 'assigned to project with rich rights' do
      let!(:assignment){FactoryGirl.create(:assignment, user_id: user.id, project_id: project.id, acl_level: 1)}
      it 'allows to read, update and delete project' do

        expect(project.available_for_read?(user)).to eq(true)
        expect(project.available_for_update?(user)).to eq(true)
        expect(project.available_for_delete?(user)).to eq(false)
      end
    end

    context 'assigned to project with poor rights' do
      let!(:assignment){FactoryGirl.create(:assignment, user_id: user.id, project_id: project.id, acl_level: 3)}
      it 'allows to read, update and delete project' do
        expect(project.available_for_read?(user)).to eq(true)
        expect(project.available_for_update?(user)).to eq(false)
        expect(project.available_for_delete?(user)).to eq(false)
      end
    end
    context 'assigned to project with super_admin rights' do
      it 'allows to read, update and delete project' do
        user.update_attributes(is_super_admin: true)
        expect(project.available_for_read?(user)).to eq(true)
        expect(project.available_for_update?(user)).to eq(true)
        expect(project.available_for_delete?(user)).to eq(true)
      end
    end
  end

end
