class Requirement < ActiveRecord::Base
	versioned

	
	before_create :set_project_id

	has_many :attachments, dependent: :destroy
	has_many :children, class_name: "Requirement", foreign_key: "parent_id", dependent: :destroy

	accepts_nested_attributes_for :attachments

	belongs_to :parent, class_name: "Requirement"
	belongs_to :project

	scope :is_active_by_project, ->(project_id) {where(is_active: true, project_id: project_id) }

	validates :title, :description, :priority, :worth, presence: true
	validates_presence_of :project_id, if: :parent_exists?

	validates_numericality_of :priority, greater_than: 0, less_than: 11
	validates_numericality_of :worth,    greater_than: 0, less_than: 11

	def authorized_for?(action)
		if action[:crud_type]==:read
			return true
		elsif current_user.is_super_admin?
			return true
		end
	end

	def available_for_create?(user)
		assignnment_exists = Assignment.where("user_id = #{user.id} AND project_id = #{self.project_id} AND acl_level <= 2").count > 0
		user.is_super_admin? || assignnment_exists
	end

	def available_for_read?(user)
		assignnment_exists = Assignment.count(conditions: {user_id: user.id, project_id: self.project_id}) > 0
		user.is_super_admin? || assignnment_exists
	end

	def available_for_update?(user)
		assignnment_exists = Assignment.where("user_id = #{user.id} AND project_id = #{self.project_id} AND acl_level <= 2").count > 0
		user.is_super_admin? || assignnment_exists
	end

	def available_for_delete?(user)
		assignnment_exists = Assignment.where("user_id = #{user.id} AND project_id = #{self.project_id} AND acl_level <= 2").count > 0
		user.is_super_admin? || assignnment_exists
	end

	def descendents
		children.map do |child|
			[child] + child.descendents if child.is_active
		end.flatten.compact
	end

	def self_and_descendents
		[self] + descendents if self.is_active
	end

	def self_and_descendents_ids
		self_and_descendents.map(&:id)
	end

	def disable_requirement
		self.is_active = false
		self.save
	end

	def disable_requirements(requirement)
		requirement.self_and_descendents.each do |requirement|
			requirement.disable_requirement
		end
	end

	private
	def set_project_id
		if self.parent
			self.project_id = self.parent.project_id
		end
	end

	def parent_exists?
		if self.parent
			true
		end
	end

end
