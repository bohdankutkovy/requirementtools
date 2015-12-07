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
    it 'returns active unassigned to project users' do
      u1 = FactoryGirl.create(:user)
      u2 = FactoryGirl.create(:user)
      u3 = FactoryGirl.create(:user)
      FactoryGirl.create(:assignment, project_id: project.id, user_id: user.id, acl_level: 3)
      FactoryGirl.create(:assignment, project_id: project.id, user_id: u1.id, acl_level: 3)
      FactoryGirl.create(:assignment, project_id: project.id, user_id: u2.id, acl_level: 3)

      expect(project.unassigned_users).to include(u3)
      expect(project.unassigned_users).not_to include(u1, u2, user)

    end
  end

end
