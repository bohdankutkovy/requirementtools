require 'spec_helper'


describe Requirement do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:requirement)).to be_valid
  end

  let(:requirement){FactoryGirl.create(:requirement)}

  let(:user){FactoryGirl.create(:user)}
  before :each do
    Requirement.destroy_all
    Project.destroy_all
  end

  describe 'ActiveModel validations' do
    it { expect(FactoryGirl.create(:requirement)).to validate_presence_of(:title) }
    it { expect(FactoryGirl.create(:requirement)).to validate_presence_of(:description) }
    it { expect(FactoryGirl.create(:requirement)).to validate_presence_of(:priority) }
    it { expect(FactoryGirl.create(:requirement)).to validate_presence_of(:worth) }

    it 'validates present of project_id' do
      parent = FactoryGirl.create(:requirement)
      requirement.update_attributes(parent_id: parent.id)
       expect(requirement).to validate_presence_of(:project_id)
    end

    it 'validates numericality of priority' do
      expect(FactoryGirl.build(:requirement, priority: 11 )).not_to be_valid
      expect(FactoryGirl.build(:requirement, priority: -1 )).not_to be_valid
      expect(FactoryGirl.build(:requirement, priority: 1 )).to be_valid
      expect(FactoryGirl.build(:requirement, priority: 10 )).to be_valid
    end

    it 'validates numericality of worth' do
      expect(FactoryGirl.build(:requirement, worth: 11 )).not_to be_valid
      expect(FactoryGirl.build(:requirement, worth: -1 )).not_to be_valid
      expect(FactoryGirl.build(:requirement, worth: 1 )).to be_valid
      expect(FactoryGirl.build(:requirement, worth: 10 )).to be_valid
    end

    describe 'Model methods' do

      let(:project){FactoryGirl.create(:project)}
      let(:parent){FactoryGirl.create(:requirement, project_id: project.id)}

      it 'returns true if parent exists' do
        requirement.update_attributes(parent_id: parent.id)
        expect(requirement.send(:parent_exists?)).to eq(true)
      end

      it 'sets project id if requirement has parent' do
        requirement.update_attributes(parent_id: parent.id)
        expect(requirement.send(:set_project_id)).to eq(parent.id)
      end

      it 'sets author of requirement' do

      end

      it 'disables requirement' do
        requirement.disable_requirement
        expect(requirement.is_active).to eq(false)
      end

      it 'return requirement and its descendents ids' do
        requirement.update_attributes(parent_id: parent.id)
        r1 = FactoryGirl.create(:requirement)
        expect(parent.self_and_descendents_ids).to include(parent.id, requirement.id)
        expect(parent.self_and_descendents_ids).not_to include(r1.id)
      end

      context 'requirement is_active' do
        it 'returns requirement and its descendents' do
          requirement.update_attributes(parent_id: parent.id)
          r1 = FactoryGirl.create(:requirement)
          expect(parent.self_and_descendents).to include(parent, requirement)
          expect(parent.self_and_descendents).not_to include(r1)
        end

        it 'returns only descendents' do
          requirement.update_attributes(parent_id: parent.id)
          r1 = FactoryGirl.create(:requirement, parent_id: requirement.id)
          expect(parent.descendents).to include(r1, requirement)
          expect(parent.descendents).not_to include(parent)
        end

      end

      context 'requirement is disabled' do
        it 'returns nothing' do
          requirement.update_attributes(parent_id: parent.id)
          parent.update_attributes(is_active: false)
          expect(parent.self_and_descendents).to be_nil
        end
        it 'returns nothing' do
          requirement.update_attributes(parent_id: parent.id)
          r1 = FactoryGirl.create(:requirement, parent_id: requirement.id)
          requirement.update_attributes(is_active: false)
          expect(parent.descendents).to eq([])
        end
      end

      it 'checks if authorized for read' do
        expect(requirement.authorized_for?({crud_type: 'read'})).to eq(true)
      end

    end
  end

end

